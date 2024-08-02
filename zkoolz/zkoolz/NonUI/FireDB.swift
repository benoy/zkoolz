//
//  FireDB.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 15/06/24.
//

import Foundation

import FirebaseFirestore

enum FireDBError: Error {
    
    case invalidDataPath
    case modelNull
    case dataUnavailable
    case unknown
}

class FireModel {
    
    var dictionary: [String: Any]?{
        get{
            return nil
        }
    }
    
    init?(dictionary: [String: Any]?) {}
    
    init(){}
}

protocol FireDBProtocol {
    func getDocs(for path: String, completion: @escaping ([QueryDocumentSnapshot]?, Error?) -> ())
    func removeDoc( at path: String, completion: @escaping (Error?) -> ())
    func getCollection(for path: String) -> DocumentReference?
    func listenDataUpdates(at path: String, completion: @escaping (Any?, Error?) -> ())
    func dataFor(path: String, completion: @escaping (Any?, Error?) -> ())
    func getDocIds(path: String, completion: @escaping (Any?, String?) -> () )
    func addDataWith(path: String, data: FireModel, completion: @escaping (Error?) -> ())
    func deleteWith(path: String, callback: @escaping (Bool) -> Void)
    func getRef(at path: String) -> NSObject?
    
    func dataFor(path: String) async -> (Any?, FireDBError?)?
    func addData(path: String, data: FireModel) async -> FireDBError?
    func updateData(path: String, data: FireModel) async -> FireDBError?
    func bulkUpdateData(path: String, data: [(String, String)]) async -> FireDBError?
}

class FireDB: FireDBProtocol {
    
    private let db = Firestore.firestore()
    
    init() {
    
        let setting = FirestoreSettings()
        setting.isPersistenceEnabled = true
        db.settings = setting
    }
    
    func getDocs(for path: String, completion: @escaping ([QueryDocumentSnapshot]?, Error?) -> ()) {
        let collection = db.collection(path)
        collection.addSnapshotListener( { snapShot, error in
            if error == nil, let docs = snapShot?.documents {
                completion(docs, nil)
            } else {
                completion(nil, error)
            }
        })
    }
    
    func removeDoc( at path: String, completion: @escaping (Error?) -> ()) {
        let docRef = getCollection(for: path)
        docRef?.delete(completion: completion)
    }
    
    func getCollection(for path: String) -> DocumentReference? {
        let doc = db.document(path)
        return doc
    }
    
    func listenDataUpdates(at path: String, completion: @escaping (Any?, Error?) -> ()) {
        
        let ref = getRef(at: path)
        if let docRef = (ref as? DocumentReference) {
            docRef.addSnapshotListener({ sanp, error in
        
                completion(sanp?.data(), error)
            })
        } else if let collectionRef = (ref as? CollectionReference){
            collectionRef.addSnapshotListener( { sanp, error in
                let data = sanp?.documents.map{ $0.data()}
                completion(data, error)
                
            })
        }
    }
    
    func dataFor(path: String, completion: @escaping (Any?, Error?) -> ()) {
        
        let ref = getRef(at: path)
        if let docRef = (ref as? DocumentReference) {
            docRef.getDocument(completion: { doc, error in
                if error == nil, let data = doc?.data() {
                     completion(data, error)
                } else {
                   completion(nil, error)
                }
            })
        } else if let collectionRef = (ref as? CollectionReference){
            collectionRef.getDocuments(completion: {objects, error in
                let profs = objects?.documents.map{ $0.data() }
                objects?.documents.map { $0.documentID }
                completion(profs, error)
                
            })
        }
    }
    
    func dataFor(path: String) async -> (Any?, FireDBError?)? {
        let ref = getRef(at: path)
        if let docRef = (ref as? DocumentReference) {
            
            return try? await withCheckedThrowingContinuation { continuation in
                docRef.getDocument(completion: { doc, error in
                    if error == nil, let data = doc?.data() {
                        continuation.resume(returning: (data, nil))
                    } else {
                        continuation.resume(returning: (nil, error as? FireDBError))
                    }
                })
            }
        } else if let collectionRef = (ref as? CollectionReference) {
            return try? await withCheckedThrowingContinuation { continuation in
                collectionRef.getDocuments(completion: { objects, error in
                    let profs = objects?.documents.map{ $0.data() }
                    continuation.resume(returning: (profs,  error as? FireDBError))
                })
            }
        }
        
        return (nil, FireDBError.unknown)
    }
    
    func getDocIds(path: String,
                   completion: @escaping (Any?, String?) -> () ) {
        guard let ref = getRef(at: path) as? CollectionReference else {
            completion(nil, "No document found in the path.")
            return
        }
        ref.getDocuments(completion: {objects, error in
            if let err = error {
                completion(nil, err.localizedDescription)
            } else {
                let profs = objects?.documents.map { $0.documentID }
                completion(profs, nil)
            }
        })
    }
    
    func addDataWith(path: String, data: FireModel, completion: @escaping (Error?) -> ()) {
        
        guard let dictData = data.dictionary else {
            return
        }
        guard let ref = getRef(at: path) else {
             return
        }
        
        if let docRef = (ref as? DocumentReference) {
            docRef.setData(dictData, completion: { error in
                completion(error)
            })
        } else if let collectionRef = (ref as? CollectionReference){
            collectionRef.addDocument(data: dictData, completion: { error in
                completion(error)
            })
        }
    }
    
    func updateData(path: String, data: FireModel) async -> FireDBError? {
        
        guard let ref = getRef(at: path) else { return .invalidDataPath }
        if let docRef = (ref as? DocumentReference), let dict = data.dictionary  {
            return try? await withCheckedThrowingContinuation { continuation in
                docRef.updateData(dict, completion: { error in
                    
                    if error != nil {
                        continuation.resume(returning: .dataUnavailable)
                    } else {
                        continuation.resume(returning: nil)
                    }
                    
                })
            }
            
        }
        return (FireDBError.unknown)
    }
    
    
    
    
    func addData(path: String, data: FireModel) async -> FireDBError? {
        
        guard let dictData = data.dictionary else { return .modelNull }
        
        guard let ref = getRef(at: path) else { return .invalidDataPath }
        
        if let docRef = (ref as? DocumentReference) {
            return try? await withCheckedThrowingContinuation { continuation in
                docRef.setData(dictData, completion: { error in
                    continuation.resume(returning: error as? FireDBError)
                })
            }
            
        } else if let collectionRef = (ref as? CollectionReference){
            return try? await withCheckedThrowingContinuation { continuation in
                collectionRef.addDocument(data: dictData, completion: { error in
                    continuation.resume(returning: error as? FireDBError)
                })
            }
        }
        
        return (FireDBError.unknown)
    }
    
    
    func deleteWith(path: String, callback: @escaping (Bool) -> Void) {
        guard let ref = getRef(at: path) else {
             return
        }
        
        if let docRef = (ref as? DocumentReference) {
            docRef.delete(completion: { error in
                callback( error == nil)
            })
        } else if let collectionRef = (ref as? CollectionReference){
           
            print(collectionRef.path)
            // Deleting collection is not recomented by Firbase instead update the same.
            callback( false )
        }
    }
    
    func getRef(at path: String) -> NSObject? {
        let comps = path.components(separatedBy: "/")
        var ref: NSObject? =  nil
        for (index, comp) in comps.enumerated() {
            if index == 0 {
                ref = db.collection(comp)
                continue
            }
            if index % 2 == 1 {
                ref = (ref as? CollectionReference)?.document(comp)
            } else if index % 2 == 0 {
                ref = (ref as? DocumentReference)?.collection(comp)
            }
        }
        
        return ref
    }
}



extension FireDB {
    
    func bulkUpdateData(path: String, data: [(String, String)]) async -> FireDBError? {
        
        guard let ref = getRef(at: path) else { return .invalidDataPath }
        
        
        if let docRef = (ref as? DocumentReference)  {
            let batch = db.batch()
            for dt in data {
                batch.updateData([dt.0: dt.1], forDocument: docRef)
            }
            return try? await withCheckedThrowingContinuation { continuation in
                batch.commit { err in
                    continuation.resume(returning: err as? FireDBError)
                }
            }
        }
        return (FireDBError.unknown)
    }
    
}


