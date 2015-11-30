import UIKit

/**
Implementação própria da célula da tabela de viagens.
*/
class TravelTableViewCell: UITableViewCell {

    /** Label que guarda o nome da viagem e informações adicionais que forem necessárias. */
    @IBOutlet weak var travelName: UILabel!
    
    //ViewCell
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
