import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

struct AssertSnapShotParam {
    
    /// The macro's parameters for extraction
    let param: AssertSnapShotParamList
    
    /// The extracted argument list parameters and expressions from the syntax tree
    let node: LabeledExprListSyntax
    
    /// The extracted expressions by parameter
    var value: ExprSyntax? {
        for child in node.children(viewMode: .all) {
            switch param {
            case .as:
                if child.as(LabeledExprSyntax.self)?.label?.trimmed.text == param.rawValue {
                    return child.as(LabeledExprSyntax.self)?.expression
                } else {
                   continue
                }
            case .of:
                if child.as(LabeledExprSyntax.self)?.label?.trimmed.text == param.rawValue {
                    return child.as(LabeledExprSyntax.self)?.expression
                } else {
                    continue
                }
            case .named:
                if child.as(LabeledExprSyntax.self)?.label?.trimmed.text == param.rawValue {
                    return child.as(LabeledExprSyntax.self)?.expression
                } else {
                    continue
                }
            case .record:
                if child.as(LabeledExprSyntax.self)?.label?.trimmed.text == param.rawValue {
                    return child.as(LabeledExprSyntax.self)?.expression
                } else {
                    continue
                }
            case .timeout:
                if child.as(LabeledExprSyntax.self)?.label?.trimmed.text == param.rawValue {
                    return child.as(LabeledExprSyntax.self)?.expression
                } else {
                    continue
                }
            }
        }
        return nil
    }
}

/// The `assertSnapshot` parameter labels
enum AssertSnapShotParamList: String {
   case `as`, `of`, named, record, timeout
}

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
            throw AssertSnapshotEqualError.message("AssertSnapshotEqual - Macro: the macro was not passed any arguments")
        }
        
        let ofArg = AssertSnapShotParam(param: .of, node: node.argumentList).value
        let asArg = AssertSnapShotParam(param: .as, node: node.argumentList).value
        let nameArg = AssertSnapShotParam(param: .named, node: node.argumentList).value
        let recordArg = AssertSnapShotParam(param: .record, node: node.argumentList).value
        let timeoutArg = AssertSnapShotParam(param: .timeout, node: node.argumentList).value

        if let nameArg, let ofArg, let asArg, let recordArg, let timeoutArg {
            return "assertSnapshot(of: \(ofArg), as: \(asArg), named: \(nameArg), record: \(recordArg), timeout: \(timeoutArg))"
        } else if let ofArg, let asArg {
            return "assertSnapshot(of: \(ofArg), as: \(asArg))"
        } else {
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
            throw AssertSnapshotEqualError.message("AssertSnapshotEqual - Macro: the macro does not have any of the expected arguments")
        }
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
