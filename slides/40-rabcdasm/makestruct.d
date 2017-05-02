static string makeStruct(string name, FieldDef[] fields,
	string extra = null, bool noBitFlush = false)()
{
	if (!__ctfe)
		return null;

	size_t[string] fieldReference;
	struct FieldProperties
	{
		string swfType, dType;
		string swfSize, dSize;
		bool needsBitFlush; // before this field
		bool optional; // skip if end of data
		bool customReader;
	}
	// +1 for needsBitFlush at the end
	auto props = new FieldProperties[fields.length + 1];

	string code;
	code ~= "\n\n////////////////////////////////////// " ~ name ~ "\n\n\n";
	code ~= `struct ` ~ name ~ "\n{\n";

	{
		size_t bitsPending;
		bool varBitsPending;

		void flushSlackBitField(size_t index)
		{
			if (varBitsPending || ((bitsPending % 8) != 0))
			{
				code ~= "ubyte slackBits_" ~ toDec(index) ~ ";\n";
				props[index].needsBitFlush = true;

				varBitsPending = false;
				bitsPending = 0;
			}
		}

		// fields
		foreach (i, field; ArrayToTuple!fields)
		{
			bool duplicate = (field.name in fieldReference) !is null;
			fieldReference[field.name] = i;

			enum FieldProperties prop = () {
				FieldProperties prop;
				prop.swfType = field.type;

				if (prop.swfType[$-1] == '?')
				{
					prop.optional = true;
					prop.swfType = prop.swfType[0..$-1];
				}
				if (prop.swfType[$-1] == '!')
				{
					prop.customReader = true;
					prop.swfType = prop.swfType[0..$-1];
				}

				auto bracketIndex = prop.swfType.indexOfElement('[');
				if (bracketIndex < 0)
					prop.swfSize = "1";
				else
				{
					assert(prop.swfType[$-1] == ']');
					prop.swfSize = prop.swfType[bracketIndex+1..$-1];
					if (prop.swfSize == "")
						prop.swfSize = "*";
					prop.swfType = prop.swfType[0..bracketIndex];
				}

				return prop;
			}();
			props[i] = prop;

			string dType;
			string dSize = prop.swfSize;
			bool isBitfield, isCustom;
			switch (prop.swfType)
			{
				case "SI8":		dType = "byte"  ; break;
				case "SI16":	dType = "short" ; break;
				case "SI32":	dType = "int"   ; break;

				case "BYTE":
				case "UI8":		dType = "ubyte" ; break;
				case "FIXED8":
				case "FLOAT16":
				case "UI16":	dType = "ushort"; break;
				case "FIXED":
				case "UI32":	dType = "uint"  ; break;
				case "UI64":	dType = "ulong" ; break;

				case "FLOAT":	dType = "float" ; break;
				case "DOUBLE":	dType = "double"; break;

				case "CHAR":	dType = "char"  ; break;
				case "STRING":	dType = "string"; break;

				case "SB":
				case "UB":
				case "FB":
				{
					string extraBits = "";
					string sizeRef = dSize;

					// Parse sizes like UB[Foo+2]
					{
						auto plusIndex = sizeRef.indexOfElement('+');
						if (plusIndex >= 0)
						{
							extraBits = sizeRef[plusIndex..$];
							sizeRef = sizeRef[0..plusIndex];
						}
					}

					dSize = "1";
					if (prop.swfType=="UB" && sizeRef == "1")
					{
						dType = "bool";
						bitsPending++;
					}
					else
					{
						string bitsExpr;
						if (isUnsignedInteger(sizeRef))
						{
							bitsExpr = sizeRef;
							bitsPending += fromDec!uint(sizeRef);
						}
						else
						if (sizeRef in fieldReference)
						{
							varBitsPending = true;
							auto sizeIndex = fieldReference[sizeRef];
							assert(props[sizeIndex].swfType == "UB",
								"Size of " ~ field.name ~ " is not a UB field");
							auto sizeBits = fromDec!uint(props[sizeIndex].swfSize);
							bitsExpr = toDec((1 << sizeBits) - 1);
						}
						else
						//if (is(typeof(mixin(field.name ~ "_bits"))))
						{
							varBitsPending = true;
							bitsExpr = sizeRef ~ "_bits";
						}

						bitsExpr ~= extraBits;

						dType = "TypeForBits!(" ~ bitsExpr ~ ")";

						if (prop.swfType == "SB")
							dType = "Signed!(" ~ dType ~ ")";
					}
					isBitfield = true;
					break;
				}
				default: // other structs
					dType = prop.swfType;
					isCustom = true;
					break;
			}

			if (i == 0)
			{
				code ~= "enum needsPreBitFlush = ";
				if (isCustom)
					code ~= dType ~ ".needsPreBitFlush";
				else
					code ~= isBitfield ? "false" : "true";
				code ~= ";\n";
				code ~= "enum needsPostBitFlush = " ~
					(noBitFlush ? "true" : "false") ~ ";\n";
			}
			else
			{
				bool needFlush;
				if (isBitfield)
					needFlush = false;
				else
				if (isCustom)
				{
					static if (is(typeof(mixin(prop.swfType ~ ".needsPreBitFlush"))))
						needFlush = mixin(prop.swfType ~ ".needsPreBitFlush");
					else
						assert(false, "Not found: " ~ prop.swfType ~ ".needsPreBitFlush");
				}
				else
					needFlush = true; // non-bitfield basic type

				if (needFlush)
					flushSlackBitField(i);

				if (isCustom)
				{
					static if (is(typeof(mixin(prop.swfType ~ ".needsPostBitFlush"))))
						varBitsPending |= mixin(prop.swfType ~ ".needsPostBitFlush");
					else
						assert(false, "Not found: " ~ prop.swfType ~ ".needsPostBitFlush");
				}
			}

			if (props[i].optional)
				code ~= "bool " ~ field.name ~ "_present;\n";

			props[i].dType = dType;
			props[i].dSize = dSize;

			if (duplicate)
			{
				// Different length/layout depending on condition
				assert(field.condition);
			}
			else
			{
				code ~= dType;
				if (!isUnsignedInteger(dSize))
					code ~= `[]`;
				else
				if (dSize != "1")
					code ~= `[` ~ dSize ~ `]`;
				code ~= ` ` ~ field.name ~ ";\n";
			}
		}

		if (!noBitFlush)
			flushSlackBitField(fields.length);
	}

	if (extra)
		code ~= extra;

	// Reader

	{
		void flushBitsR(size_t index)
		{
			if (props[index].needsBitFlush)
			{
				auto fieldName = "slackBits_" ~ toDec(index);
				code ~= "\t\tthis." ~ fieldName ~ " = context.bitReader.getSlack();\n";
			}
		}

		code ~= "\nthis(ref ubyte[] bytes)\n{\n";
		foreach (i, field; fields)
		{
			if (props[i].optional)
				code ~= "\tif (bytes.length)\n";

			if (field.condition)
				code ~= "\tif (" ~ field.condition ~ ")\n";

			code ~= "\t{\n";

			flushBitsR(i);

			auto fieldRef = "this." ~ field.name;
			string op = "=";
			if (props[i].customReader)
			{
				code ~= "\t\t" ~ fieldRef ~ ` ` ~ op ~
					" this.read" ~ field.name ~ "(bytes);\n";
				goto readEnd;
			}
			else
			if (props[i].dSize == "*")
			{
				if (props[i].swfType == "BYTE")
				{
					code ~= "\t\t" ~ fieldRef ~ ` ` ~ op ~
						" Reader.readRaw(bytes, bytes.length);\n";
					goto readEnd;
				}

				code ~= "\t\twhile (bytes.length)\n";
				op = "~=";
			}
			else
			if (!isUnsignedInteger(props[i].dSize))
			{
				code ~= "\t\tforeach (_; 0.."~props[i].dSize~")\n";
				op = "~=";
			}
			else
			if (props[i].dSize != "1")
			{
				if (props[i].swfType == "BYTE")
				{
					code ~= "\t" ~ fieldRef ~ ` ` ~ op
						~ ` Reader.readRaw(bytes, ` ~ props[i].dSize ~ ");\n";
					continue;
				}

				code ~= "\t\tforeach (ref "~field.name~"Element; "~fieldRef~")\n";
				fieldRef = field.name~"Element";
			}

			code ~= "\t\t{\n\t\t\t" ~ fieldRef ~ ` ` ~ op ~ ` `;
			switch (props[i].swfType)
			{
				case "STRING":
					code ~= `Reader.readString(bytes)`;
					break;
				case "SB":
				case "UB":
				case "FB":
					if (props[i].dType == "bool")
						code ~= `context.bitReader.read(bytes)`;
					else
						code ~= `context.bitReader.read!(`~props[i].dType~`)` ~
							`(bytes, `~props[i].swfSize~`)`;
					break;
				default:
					if (props[i].dType == props[i].swfType)
						code ~= props[i].dType~`(bytes)`;
					else
						code ~= `Reader.read!`~props[i].dType~`(bytes)`;
					break;
			}
			code ~= ";\n";
			code ~= "\t\t\tstatic if (is(typeof(context."~name~"_"~field.name~")))" ~
				"context."~name~"_"~field.name~" = this."~field.name~";\n";
			code ~= "\t\t}\n"; // end loop
		readEnd:
			if (props[i].optional)
				code ~= "\t\tthis."~field.name~"_present = true;\n";
			code ~= "\t}\n"; // end cond
		}
		flushBitsR(fields.length);
		code ~= "\tstatic if(is(typeof(postRead))) postRead(context);\n";
		code ~= "}\n\n";
	}

	debug(SWFVisitor)
	{
		code ~= "import autodata;\n";
		code ~= "mixin AutoToString;\n";
		code ~= "mixin ProcessAllData;\n";
	}

	// Writer
	{
		void flushBitsW(size_t index)
		{
			if (props[index].needsBitFlush)
				code ~= "\tbuf ~= context.bitWriter.flush(this.slackBits_" ~
					toDec(index) ~ ");\n";
		}

		code ~= "ubyte[] toBytes()\n{\n";
		code ~= "\tstatic if(is(typeof(preWrite))) preWrite(context);\n";
		code ~= "\tubyte[] buf;\n";
		foreach (i, field; fields)
		{
			if (props[i].optional)
				code ~= "\tif (" ~ field.name ~ "_present)\n";

			if (field.condition)
				code ~= "\tif (" ~ field.condition ~ ")\n";

			code ~= "\t{\n";
			flushBitsW(i);

			auto fieldName = field.name;
			if (props[i].dSize != "1")
			{
				if (props[i].swfType == "BYTE")
				{
					code ~= "\t\t{ ";
					if (props[i].dSize != "*")
						code ~= "assert("~fieldName~".length == "~props[i].dSize~"); ";
					code ~= "buf ~= " ~ fieldName ~ "; }\n";
					goto writeEnd;
				}

				code ~= "\t\tforeach (ref "~fieldName~"Element; "~fieldName~")";
				fieldName ~= "Element";
			}

			code ~= "\t\t{\n\t\t\tbuf ~= ";
			switch (props[i].swfType)
			{
				case "STRING":
					code ~= `.toBytes(`~fieldName~`)`;
					break;
				case "SB":
				case "UB":
				case "FB":
					if (props[i].dType == "bool")
						code ~= `context.bitWriter.write(`~fieldName~`)`;
					else
						code ~= `context.bitWriter.write(`~fieldName~`, ` ~
							props[i].swfSize~`)`;
					break;
				default:
					if (props[i].dType == props[i].swfType)
						code ~= fieldName~`.toBytes()`;
					else
						code ~= `toArray(`~fieldName~`)`;
					break;
			}
			code ~= ";\n";
			code ~= "\t\t\tstatic if (is(typeof(context."~name~"_"~field.name~")))" ~
				"context."~name~"_"~field.name~" = this."~field.name~";\n";
			code ~= "\t\t}\n"; // end loop
		writeEnd:
			code ~= "\t}\n"; // end cond
		}
		flushBitsW(fields.length);
		code ~= "\treturn buf;\n";
		code ~= "}\n"; // end writer
	}

	code ~= "}\n"; // end struct

	return code;
}
