//
//  Cripto.swift
//  N4
//
//  Created by Teclógica Serviços em Informática LTDA on 22/11/15.
//  Copyright © 2015 FURB. All rights reserved.
//

import Foundation

/**
Implementação do algoritmo de criptografia AES128 com IV e Salt.
*/
class AES128Encryptor {
    
    /** Algoritmo utilizado: AES128. */
    let algorithm:CCAlgorithm = UInt32(kCCAlgorithmAES128)
    /** Opções de criptografia: Padding. */
    let options:CCOptions = UInt32(kCCOptionPKCS7Padding)
    /** Tamanho da chave. */
    let keySize:Int = kCCKeySizeAES128
    /** Tamanho do bloco. */
    let blockSize:Int = kCCBlockSizeAES128
    /** Tamanho do vetor inicial. */
    let algorithmIVSize:Int = kCCBlockSizeAES128
    /** Tamanho do salt utilizado (pode ser mudado). */
    let saltSize:Int = 8
    /** Quantidade de voltas. */
    let rounds:UInt32 = 10000
    
    /** Chave do vetor de inicialização no NSDefaults. */
    let IV_KEY = "IV_KEY"
    /** Chave da chave de criptografia... BEM SEGURO NÉ */
    let KEY_KEY = "KEY_KEY"
    
    init() {
        try! self.checkForKey()
    }
    
    /**
    Verifica se a chave já foi criada, caso não, cria a chave e salva no keychain.
    */
    private func checkForKey() throws {
        if NSUserDefaults.standardUserDefaults().dataForKey(KEY_KEY) == nil {
            try self.createKey()
        }
    }
    
    /**
    Cria a chave simétrica AES128 e a salva no keychain.
    */
    private func createKey() throws {
        
        let password = NSUUID().UUIDString.dataUsingEncoding(NSUTF8StringEncoding)!
        let salt = try self.randomDataOfLength(saltSize)
        let iv = try self.randomDataOfLength(algorithmIVSize)
        
        NSUserDefaults.standardUserDefaults().setValue(iv, forKey:IV_KEY)
        NSUserDefaults.standardUserDefaults().setValue(self.AESKeyFromPassword(password, salt: salt), forKey:IV_KEY)
        
    }
    
    /**
    - Parameter length: tamanho do bloco de dados.
    - Returns: Novo bloco aleatório de bytes.
    */
    private func randomDataOfLength(length:Int) throws -> NSData {
        let data:NSMutableData = NSMutableData(length: length)!
        let dataPointer = UnsafeMutablePointer<UInt8>(data.mutableBytes)
        if SecRandomCopyBytes(kSecRandomDefault, length, dataPointer) != 0 {
            print("Error while creating random data")
        }
        return data
    }
    
    /**
    Cria senha AES128 com o password e salt passados.
    - Parameters:
    - password
    - salt
    - Returns: Senha AES128.
    */
    private func AESKeyFromPassword(password:NSData, salt:NSData) -> NSData {
        let algorithm:CCPBKDFAlgorithm = UInt32(kCCPBKDF2)
        let prfAlgorithm:CCPseudoRandomAlgorithm = UInt32(kCCPRFHmacAlgSHA1)
        let newKey = NSMutableData(length:keySize)!
        let newKeyPointer = UnsafeMutablePointer<UInt8>(newKey.mutableBytes)
        let saltPointer = UnsafePointer<UInt8>(salt.bytes)
        let passwordString = String(data:password, encoding:NSUTF8StringEncoding)!
        CCKeyDerivationPBKDF(algorithm, passwordString, passwordString.characters.count, saltPointer, salt.length, prfAlgorithm, rounds, newKeyPointer, newKey.length)
        return newKey
    }
    
    /**
    Criptografa os dados passados.
    - Parameter data
    - Returns: Dados criptogradados.
    - Throws Error
    */
    func encrypt(data:NSData) throws -> NSData {
        
        let resultBuffer = NSMutableData(length: Int(data.length + blockSize))!
        let resultBufferPointer = UnsafeMutablePointer<UInt8>(resultBuffer.mutableBytes)
        var bytesEncrypted:Int = 0
        
        let operation:CCOperation = UInt32(kCCEncrypt)
        
        let key = NSUserDefaults.standardUserDefaults().dataForKey(KEY_KEY)!
        let iv = NSUserDefaults.standardUserDefaults().dataForKey(IV_KEY)!
        
        if CCCrypt(operation, algorithm, options, key.bytes, key.length, iv.bytes, data.bytes, data.length, resultBufferPointer, resultBuffer.length, &bytesEncrypted) != 0 {
            print("Erro")
        }
        
        return resultBuffer
    }
    
    func decrypt(data:NSData) throws -> NSData {
        
        let resultBuffer = NSMutableData(length: Int(data.length))!
        let resultBufferPointer = UnsafeMutablePointer<UInt8>(resultBuffer.mutableBytes)
        var bytesEncrypted:Int = 0
        
        let operation:CCOperation = UInt32(kCCDecrypt)
        
        let key = NSUserDefaults.standardUserDefaults().dataForKey(KEY_KEY)!
        let iv = NSUserDefaults.standardUserDefaults().dataForKey(IV_KEY)!
        
        if CCCrypt(operation, algorithm, options, key.bytes, key.length, iv.bytes, data.bytes, data.length, resultBufferPointer, resultBuffer.length, &bytesEncrypted) != 0 {
            print("Cant decrypt")
        }
        
        return NSData(bytes:resultBuffer.bytes, length:data.length - blockSize)
    }
    
    
}