//
//  LionessRunner.swift
//  macOS Example
//
//  Created by Louis D'hauwe on 15/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation
import Lioness

class Lioness {
	
	fileprivate var logDebug: Bool
	
	init(logDebug: Bool = false) {
		self.logDebug = logDebug
	}
	
	func runSource(atPath path: String) throws {
		
		let source = try String(contentsOfFile: path, encoding: .utf8)
		
		runSource(source)
	}
	
	func runSource(_ source: String) {
		
		let startTime = CFAbsoluteTimeGetCurrent()
		
		if logDebug {
			printSourceCode(source)
		}
		
		runLionessSourceCode(source)
		
		if logDebug {
			
			let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
			log("\nTotal execution time: \(timeElapsed)ms")
			
		}
		
	}
	
	fileprivate func runLionessSourceCode(_ source: String) {
		
		let tokens = runLexer(withSource: source)
		
		guard let ast = parseTokens(tokens) else {
			return
		}
		
		guard let bytecode = compileToBytecode(ast: ast) else {
			return
		}
		
		interpretBytecode(bytecode)
		
	}
	
	fileprivate func printSourceCode(_ source: String) {
		
		log("================================")
		log("Source code")
		log("================================\n")
		
		for s in source.components(separatedBy: "\n") {
			log(s)
		}
		
	}
	
	fileprivate func runLexer(withSource source: String) -> [Token] {
		
		if logDebug {
			
			log("\n================================")
			log("Start lexer")
			log("================================\n")
			
		}
		
		let lexer = Lexer(input: source)
		let tokens = lexer.tokenize()
		
		if logDebug {
			
			log("Number of tokens: \(tokens.count)")
			
			for t in tokens {
				log(t)
			}
			
		}
		
		return tokens
		
	}
	
	fileprivate func parseTokens(_ tokens: [Token]) -> [ASTNode]? {
		
		if logDebug {
			log("\n================================")
			log("Start parser")
			log("================================\n")
		}
		
		let parser = Parser(tokens: tokens)
		
		var ast: [ASTNode]? = nil
		
		do {
			
			ast = try parser.parse()
			
			if logDebug {
				
				log("Parsed AST:")
				
				if let ast = ast {
					for a in ast {
						log(a.description)
					}
				}
				
			}
			
			return ast
			
		} catch {
			
			if logDebug {
				log(error)
			}
			
			return nil
			
		}
		
	}
	
	fileprivate func compileToBytecode(ast: [ASTNode]) -> [BytecodeInstruction]? {
		
		if logDebug {
			
			log("\n================================")
			log("Start bytecode compiler")
			log("================================\n")
			
		}
		
		let bytecodeCompiler = BytecodeCompiler(ast: ast)
		
		var bytecode: [BytecodeInstruction]? = nil
		
		do {
			
			bytecode = try bytecodeCompiler.compile()
			
			if logDebug {
				
				if let bytecode = bytecode {
					for b in bytecode {
						log(b.description)
					}
				}
				
			}
			
			return bytecode
			
		} catch {
			
			if logDebug {
				
				log(error)
				
			}
			
			return nil
			
		}
		
	}
	
	fileprivate func interpretBytecode(_ bytecode: [BytecodeInstruction]) {
		
		if logDebug {
			
			log("\n================================")
			log("Start bytecode interpreter")
			log("================================\n")
			
		}
		
		let interpreter = BytecodeInterpreter(bytecode: bytecode)
		
		do {
			
			try interpreter.interpret()
			
			if logDebug {

				log("Stack at end of execution:\n\(interpreter.stack)")
				log("Registers at end of execution:\n\(interpreter.registers)")

			}
			
		} catch {
			
			if logDebug {
				
				log(error)
				
			}
			
		}
		
	}
	
	fileprivate func log(_ message: String) {
		print(message)
	}
	
	fileprivate func log(_ error: Error) {
		print(error)
	}
	
	fileprivate func log(_ token: Token) {
		print(token)
	}
	
}