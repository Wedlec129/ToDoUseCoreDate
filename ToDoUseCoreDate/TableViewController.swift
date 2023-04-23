//
//  TableViewController.swift
//  ToDoUseCoreDate
//
//  Created by Борух Соколов on 23.04.2023.
//

import UIKit
import CoreData //используем фреймворк

class TableViewController: UITableViewController {

    var tasks: [Task] = [] //масств наших записей нашего класса (ENTITES)
    
    
    //определяем редактирование на удаление
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    
    //определяем если событие удалить
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            //удаляем в массиве и в отображении)
            //objects.remove(at: indexPath.row)
            //tableView.deleteRows(at: [indexPath], with: .fade) //tableView.reloadData()
            
          let context = getContext()
            
          let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
           if let objects = try? context.fetch(fetchRequest) {
              
                context.delete(objects[indexPath.row])
               tableView.reloadData()
               
           }
   
           do {
               try context.save()
           } catch let error as NSError {
               print(error.localizedDescription)
           }
    
            
        }
        
    }
    
    
    //ф-я которая срабытывает перед всеми
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let context = getContext() //получаем контекст
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest() //получаем все ранее сохранённые обекты
            //сортировка
        //let sortDescriptor =  (key: "title", ascending: false)
        // fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            tasks = try context.fetch(fetchRequest) //наш массив = всем обекстам сохранённым
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //          удаление данных
        //        let context = getContext()
        //        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        //        if let objects = try? context.fetch(fetchRequest) {
        //            for object in objects {
        //                context.delete(object)
        //            }
        //        }
        //
        //        do {
        //            try context.save()
        //        } catch let error as NSError {
        //            print(error.localizedDescription)
        //        }
        
        
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        //cell.textLabel?.text=tasks[indexPath.row]

        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        
        return cell
    }
    

   
    //когда нажали на плюстк
    @IBAction func addNewEvent(_ sender: Any) {
 
        //настраиваем сообщение
        let alertController = UIAlertController(title: "New Task", message: "Please add a new task", preferredStyle: .alert)
        alertController.addTextField { _ in }
        
        //кнопка сохранения
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let tf = alertController.textFields?.first //текстовое поле
            
            //берём значение поля
            if let newTaskTitle = tf?.text {
                // self.tasks.insert(newTask, at: 0)
                
                self.saveTask(withTitle: newTaskTitle) //используем ф-я сохранения
                
                self.tableView.reloadData()  //обновляем таблицу
            }
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
        
    }
    
    
    //ф-я сохранения приватная для нашего удобства :)
    private func saveTask(withTitle title: String) {
        
        //context and enttiti
        let context = getContext()
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        
        //так как мы получили контекст и сущность то можем сохранить
        let taskObject = Task(entity: entity, insertInto: context)
        taskObject.title = title    //передаём значение
        
        
        //мы внесли в наш контекст изменеия
        //значит нам надо сохранит контекст
        do {
            try context.save() //сохраняем контест
            tasks.append(taskObject) // заполняем наш массив
            
        } catch let error as NSError { //если ошибка
            print(error.localizedDescription)
        }
    }
    
    
    //ф-я даёт контекст
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    
    
    
}
