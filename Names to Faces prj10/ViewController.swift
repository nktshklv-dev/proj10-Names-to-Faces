//
//  ViewController.swift
//  Names to Faces prj10
//
//  Created by Nikita  on 6/21/22.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var people = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        let defaults = UserDefaults.standard
        if let savedPeople = defaults.object(forKey: "people") as? Data{
            if let decodedPeople = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPeople) as? [Person]{
                people = decodedPeople
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? Person_Cell else{
            fatalError()
        }
        let person = people[indexPath.item]
        cell.imageTitle.text = person.name
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        cell.imageView.layer.borderColor = UIColor.gray.cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        return cell
    }

    @objc func addNewPerson(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else{
            return
        }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 1){
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unkown", image: imageName)
        people.append(person)
        save()
        collectionView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        let firstAc = UIAlertController(title: "Do you want to delete the person, or just rename the picture?", message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
            [weak self] _ in
            self?.people.remove(at: indexPath.item)
            self?.save()
            collectionView.reloadData()
        })
        
        
        let secondAc = UIAlertController(title: "Rename", message: nil, preferredStyle: .alert)
        secondAc.addTextField()
        secondAc.addAction(UIAlertAction(title: "Submit", style: .default, handler: {
            [weak self, weak secondAc] _ in
            guard let text = secondAc?.textFields![0].text else {return}
            person.name = text
            self?.save()
            self?.collectionView.reloadData()
        }))
        secondAc.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        let renameAction = UIAlertAction(title: "Rename", style: .default, handler: {
            [weak self] _ in
            self?.present(secondAc, animated: true, completion: nil)
        })
        
        firstAc.addAction(renameAction)
        firstAc.addAction(deleteAction)
        
        present(firstAc, animated: true, completion: nil)
    }
    
    
    func save(){
        if let savedData =  try? NSKeyedArchiver.archivedData(withRootObject: people, requiringSecureCoding: false){
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "people")
        }
    }
}

