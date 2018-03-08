//
//  CoreDataManager.swift
//  Notes
//
//  Created by MACBOOK AIR on 12/02/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import CoreData

final class CoreDataManager {

    private let modelName: String
    
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    
    private(set) lazy var mainManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        managedObjectContext.parent = self.privateManagedObjectContext
        return managedObjectContext
    }()
    
    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        // Managed Object Context
        // Instanciando uma nova propriedade Managed Object Context, .mainQueueConcurrencyType
        // Significa que a Thread utilizada será a principal
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        // Settando quem será o Coordenador de Persistencia
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        // Para instancia uma novo objeto de Managed Object Model, devemos pegar a URL do arquivo presente no Bundle
        // Da aplicação
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            fatalError("Unable to Find Data Model")
        }
        
        // Instanciando um novo objeto Managed Object Model
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to Load Data Model")
        }
        return managedObjectModel
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // Para instanciar uma novo objeto de Persistent Store Coordinator
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        // Configuração do Persistent Store - No vamos utilizar o SQLite, no qual o CoreData possui compatibilidade
        // Esse arquivo será armazenado no dispositivo, no diretório de documentos do Sandbox
        let fileManager = FileManager.default
        let storeName   = "\(self.modelName).sqlite"
        
        // URL Diretório de Documentos Sandbox
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory , in: .userDomainMask)[0]
        
        // URL Persistent Store
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)

        // Adicionando o Persistent Store ao Coordinator
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                           NSInferMappingModelAutomaticallyOption: true]
            // No primeiro parametro passamos qual o tipo do Persistent Store
            // Ele vai buscar pelo nome do local, caso ele não encontre o Persistent Store ele o cria automaticamente
            // Caso ele encontre ele adiciona ao Persistent Coordinator
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType , configurationName: nil, at: persistentStoreURL, options: options)
        } catch {
            fatalError("Error adding Persistent Store")
        }
        return persistentStoreCoordinator
    }()
    
    init(modelName:String) {
        self.modelName = modelName
        setupNotificationHandling()
    }
    
    private func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(saveChanges(_:)), name: Notification.Name.UIApplicationWillTerminate , object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(saveChanges(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    @objc func saveChanges(_ notification: Notification) {
        saveChanges()
    }
    
    private func saveChanges() {
        mainManagedObjectContext.perform({
            do {
                if self.mainManagedObjectContext.hasChanges {
                    try self.mainManagedObjectContext.save()
                }
            } catch {
                let saveError = error as NSError
                print("Unable to Save Changes of Main Managed Object Context")
                print("\(saveError), \(saveError.localizedDescription)")
            }
            
            self.privateManagedObjectContext.perform({
                do {
                    if self.privateManagedObjectContext.hasChanges {
                        try self.privateManagedObjectContext.save()
                    }
                } catch {
                    let saveError = error as NSError
                    print("Unable to Save Changes of Private Managed Object Context")
                    print("\(saveError) \(saveError.localizedDescription)")
                }
            })
        })
    }
}


