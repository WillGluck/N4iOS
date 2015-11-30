//
//  TravelTableViewCell.swift
//  N4
//
//  Created by Teclógica Serviços em Informática LTDA on 18/11/15.
//  Copyright © 2015 FURB. All rights reserved.
//

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
