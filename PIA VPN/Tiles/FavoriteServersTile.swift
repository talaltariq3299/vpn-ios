//
//  FavoriteServersTile.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 03/04/2019.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.

//

import Foundation
import PIALibrary

class FavoriteServersTile: UIView, Tileable {
    
    var view: UIView!
    var detailSegueIdentifier: String!
    var status: TileStatus = .normal {
        didSet {
            statusUpdated()
        }
    }
    
    @IBOutlet private weak var tileTitle: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.xibSetup()
        self.setupView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupView() {
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(viewShouldRestyle), name: .PIAThemeDidChange, object: nil)
        nc.addObserver(self, selector: #selector(updateFavoriteList), name: .PIAServerHasBeenUpdated, object: nil)
        
        viewShouldRestyle()
        self.tileTitle.text = L10n.Tiles.Favorite.Servers.title.uppercased()
        updateFavoriteList()
        
    }
    
    @objc private func viewShouldRestyle() {
        tileTitle.style(style: TextStyle.textStyle21)
        Theme.current.applyPrincipalBackground(self)
    }
    
    @objc private func updateFavoriteList() {
        var currentServers = Client.providers.serverProvider.currentServers
        currentServers.append(Server.automatic)
        for containerView in stackView.subviews {
            if let button = containerView.subviews.first as? ServerButton {
                button.setImage(Theme.current.palette.appearance == .light ? Asset.Piax.Tiles.quickConnectPlaceholderLight.image :
                    Asset.Piax.Tiles.quickConnectPlaceholderDark.image, for: .normal)
                button.imageView?.contentMode = .scaleAspectFit
                button.isUserInteractionEnabled = false
                button.accessibilityLabel = L10n.Global.empty
            }
        }
        
        var favServers: [Server] = []
        for identifier in AppPreferences.shared.favoriteServerIdentifiers.reversed() {
            if let server = currentServers.first(where: { return $0.identifier == identifier }) {
                favServers.append(server)
            }
        }
        
        for (index, server) in favServers.enumerated() where index < stackView.subviews.count {
            let view = stackView.subviews[index]
            if let button = view.subviews.first as? ServerButton {
                button.alpha = 1
                button.setImage(fromServer: server)
                button.imageView?.contentMode = .scaleAspectFit
                button.isUserInteractionEnabled = true
                button.server = server
                button.accessibilityLabel = server.description
            }
        }
        
    }
    
    @IBAction private func connectToServer(_ sender: ServerButton) {
        if let server = sender.server {
            self.connectTo(server: server)
        }
    }
    
    private func statusUpdated() {
        updateFavoriteList()
    }
    
}
