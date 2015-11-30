import UIKit
import CoreData

/**
 View Controller responsável pela tela de criação de novas viagens.
 */
class NewTravelViewController: UIViewController {

    /** Input text do nome da viagem. */
    @IBOutlet weak var travelName: UITextField!
    /** Switch indicando se a viagem é segura ou não. */
    @IBOutlet weak var secure: UISwitch!
    
    //Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Navigation.
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mapUnwindSegue" {
            if let travelName = self.travelName.text {
                self.createTravel(travelName)
                self.prepareMapView(segue.destinationViewController as! MapViewController)
            }
        }
    }
    
    //Métodos
    
    /**
    Prepara o MapViewController com a viagem selecionada.
    - Parameter mapViewController: Referência ao viewController a ser configurado.
    */
    func prepareMapView(mapViewController:MapViewController) {
        if let travelName = self.travelName.text {
            mapViewController.loadTravel(travelName)
        }
    }
    
    /**
     Cria uma viagem com o nome passado.
     - Parameter travelName: Nome da viagem a ser criada.
     */
    func createTravel(travelName:String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let travel =  NSEntityDescription.insertNewObjectForEntityForName("Travel", inManagedObjectContext: managedContext)
        travel.setValue(travelName, forKey: "name")
        travel.setValue(self.secure.on, forKey: "secure")
        travel.setValue(false, forKey: "finished")
        
        try! managedContext.save()
    }
}
