import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

/// Implementation of the `AssertSnapshot` macro
///
///     #AssertSnapshotEqual(of: "Sample", as: .lines)
///
public struct AssertSnapshotEqualMacro: ExpressionMacro {
    
    /// Parse the given abstract syntax tree for the macro's signature, extracting the paramters and creating the assertSnapshot(of:as:named:)  expression
    /// - Parameters:
    ///   - node: The macro's tree of syntax nodes
    ///   - context: The macro's expansion context
    /// - Returns: The expression syntax representation of the function call.
    public static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
        guard !node.argumentList.children(viewMode: .all).isEmpty else {
            context.diagnose(
                  Diagnostic(
                    node: Syntax(node),
                    message: AssertSnapshotEqualDiagnosticMessage(
                      message: "Failed to parse the incoming arg parameters (of:as:named:)",
                      diagnosticID: MessageID(domain: "#AssertSnapshotEqual - Macro", id: "error"),
                      severity: .error
                    )
                  )
                )
            throw AssertSnapshotEqualError.message("AssertSnapshotEqual - Macro: the macro was not passed any arguments")
        }
        // Pass the incoming macro signature to the generated assertSnapshot(...) expression
        return "assertSnapshot(\(node.argumentList))"
    }
}

@main
struct AssertSnapshotEqualPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AssertSnapshotEqualMacro.self,
    ]
}

private struct AssertSnapshotEqualDiagnosticMessage: DiagnosticMessage, Error {
  let message: String
  let diagnosticID: MessageID
  let severity: DiagnosticSeverity
}

extension AssertSnapshotEqualDiagnosticMessage: FixItMessage {
  var fixItID: MessageID { diagnosticID }
}

private enum AssertSnapshotEqualError: Error, CustomStringConvertible {
  case message(String)

  var description: String {
    switch self {
    case .message(let text):
      return text
    }
  }
}
