# Part 4

### RABCDAsm

Notes:

22. RABCDAsm
    - "I like video games,"
      - "and if I particularly like a game I may tinker with it, so to say play the game and maybe play with the game itself"
      - "This is one of my first D projects concerning game modding"
    - Explain name ("It is called RABCDAsm (No I am not very good at naming things)")
      - Explain in brief what ABC and AVM is
        - "RABCDAsm is an assembler slash disassembler for ActionScript Byte Code"
        - "ActionScript is the language used in Adobe Flash files"
        - Optional details:
          - "RABCDAsm only concerns itself with version 3 of the language, which is an optionally typed superset of JavaScript with things like namespaces and classes"
          - "The way the toolchain works is that "
            - "the ActionScript compiler takes ActionScript source code and compiles it to ActionScript bytecode, "
            - "which is then embedded in SWF files."
            - "When the Flash player loads the files, it passes the ABC blocks to the ActionScript Virtual Machine"
          - Explain what R means
23. -"-
24. .
    - Describe need for autodata
      - "I will spare you the details of the Flash and ABC file format"
        - Mention that jailed programmer?
      - Suffice to say that it involves many, many data structures, which often consist of discriminated unions
      - In the process of assembling the ABC, we need to build a number of constant pools
        - Which means we need comparison and equality tests as well as hash calculation for all relevant types
25. .
    - Quickly skip over implementation
      - Basically explain code generation (build code as a string in CTFE, mix it in)
      - Mention that it's dated and not idiomatic D
      - Mention Lucia's __cmp work
26. . 
    - Show examples:
      - Generate opCmp for the entire struct
      - using a custom `processData` for discriminated union
27. . 
    - swffile stuff
      - Example:
        - Show RECT example from PDF, and our DSL
      - Conditions example:
        - Same with MATRIX struct
      - Custom reader example:
        - DefineButton2
    - Quick overview of code
      - "On the code generation side you can see that it's pretty simple"
      - (show slide)
      - "Well, it's a lot of code but that's mainly because of the inconsistencies in the file format."
      - "The basic idea is to just use basic string processing to build the struct declaration, along with the reader and writer methods"
      - "Because all the data is given to us in the FieldDefs, we don't even need to do any introspection like with JSON"
28. -"-
29. Finalize RABCDAsm
    - remnux
    - Reflash (https://github.com/F-Secure/reflash)
    - game modding tool in general
