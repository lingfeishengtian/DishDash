//
//  CustomerManager.swift
//  DishDash
//
//  Created by Hunter Han on 11/16/24.
//

import Foundation

/// Base Customer Rate defines the beginning time for another customer spawning
fileprivate let baseCustomerSpawnRate: Int = 10
/// Number of customers before spawnRate is reduced by 1
fileprivate let numCustomersBeforeDifficultySpike: Int = 2
fileprivate let minimumSpawnRate: Int = 2

/// Same concept as baseCustomerSpawnRate but for how long the customer will wait before losing the game
fileprivate let baseCustomerTimeLimit: Int = 20
fileprivate let numCustomersBeforeTimeLimitSpike: Int = 2

extension GameScene {
    func stopAllCustomerTimers() {
        customerGeneratorTimer?.invalidate()
        for customer in customersAtTables {
            customer.stopCountdown()
            customer.removeFromParent()
        }
        
        for customer in queuedCustomersOutside {
            customer.stopCountdown()
            customer.removeFromParent()
        }
        
        customersAtTables.removeAll()
        queuedCustomersOutside.removeAll()
    }
    
    func startNewCustomerTimer() {
        customerGeneratorTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timeIntervalBasedOnDifficulty()), repeats: false) { [weak self] _ in
            self?.addCustomer()
        }
    }
    
    func addCustomer() {
        let newCustomer = Customer(order: FoodOrderCategory.randomOrderableItem(for: .Sushi), timeLimit: timeLimitForCustomer(), size: CGSize(width: 50, height: 50)) {
            self.logger.info("Customer left")
            self.loseGame()
        }
        
        if let reservedTable = reserveTable(for: newCustomer) {
            newCustomer.position = reservedTable
            self.addChild(newCustomer)
            
            customersAtTables.append(newCustomer)
            customersSinceStart += 1
            
            startNewCustomerTimer()
        } else {
            // TODO: Implement outside queueing
            loseGame()
        }
    }
    
    /// Reduce seconds linearly from baseCustomerTimeLimit to numCustomersBeforeTimeLimitSpike based on customers since start
    func timeLimitForCustomer() -> Int {
        return max(
            baseCustomerTimeLimit - customersSinceStart / numCustomersBeforeTimeLimitSpike,
            7
        )
    }
    
    /// Reserves a table at a TilePoint (sets the customer's table to this tile point) and returns the coordinates that customer should "sit" at
    func reserveTable(for customer: Customer) -> CGPoint? {
        let positions = getPositionsOfTileGroup(for: TileType.table)
        
        for tablePosition in positions {
            if !customersAtTables.contains(where: { $0.tableSittingAt == tablePosition }) {
                customer.tableSittingAt = tablePosition
                
                // TODO: Handle table positioning code (x - 1) is a placeholder
                return self.convert(tileMap.centerOfTile(atColumn: tablePosition.x - 1, row: tablePosition.y), from: tileMap)
            }
        }
        
        return nil
    }
    
    /// Reduce seconds linearly from baseCustomerSpawnRate to numCustomersBeforeDifficultySpike based on customers since start
    /// Minimum time interval is 2 seconds
    private func timeIntervalBasedOnDifficulty() -> Int {
        return max(
            baseCustomerSpawnRate - customersSinceStart / numCustomersBeforeDifficultySpike,
            minimumSpawnRate
        )
    }
    
    func removeCustomer(_ customer: Customer) {
        customersAtTables.removeAll { $0 == customer }
        customer.removeFromParent()
    }
}
