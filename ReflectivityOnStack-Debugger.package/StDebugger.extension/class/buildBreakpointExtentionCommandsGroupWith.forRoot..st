*ReflectivityOnStack-Debugger
buildBreakpointExtentionCommandsGroupWith: stDebuggerInstance forRoot: rootCommandGroup

    <extensionCommands>
    | commands codeGroup |
    commands := { StBreakOnStackCommand } collect: [ :class |class forSpecContext: stDebuggerInstance ].


    codeGroup := rootCommandGroup
                 / StDebuggerCodeCommandTreeBuilder groupName
                 / StDebuggerCodeCommandTreeBuilder new
                     codeDebugCommandsGroupName.
    commands do: [ :c | codeGroup register: c ]