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
        customerGeneratorTimer?.stop()
        
        for customer in customersAtTables {
            customer.stopTimer()
            customer.removeFromParent()
        }
        
        for customer in queuedCustomersOutside {
            customer.stopTimer()
            customer.removeFromParent()
        }
        
        customersAtTables.removeAll()
        queuedCustomersOutside.removeAll()
    }
    
    func startNewCustomerTimer() {
        customerGeneratorTimer = PausableTimer(time: timeIntervalBasedOnDifficulty(), tickTime: 0.01) { [weak self] tick in
            guard let self = self else { return }
            changeTimeTillNextCustomerLabel(to: tick)
        } onCompletion: { [weak self] in
            self?.addCustomer()
        }
        customerGeneratorTimer?.start()
        clearHighlights()
    }
    
    func addCustomer(_ customer: Customer) -> Bool {
        if let reservedTable = reserveTable(for: customer) {
            customer.position = reservedTable
            self.addChild(customer)
            
            customersAtTables.append(customer)
            
            /// Fire table events for food on table tiles
            for food in getAllFoodOnscreen() {
                let tilePosition = position(of: food)
                if tileGroup(at: tilePosition) == .table {
                    eventTableTile(food, at: tilePosition)
                }
            }
            
//            if customer.parent != nil && showTutorialIndicator && tutorialActionSequence.isEmpty && !inTutorialPhase {
//                tutorialActionSequence = customer.order.tutorialSequence
//                initiateTutorial()
//            }
            
            return true
        }
        
        return false
    }
    
    func addCustomer() {
        let newCustomer = Customer(order: FoodOrderCategory.randomOrderableItem(for: foodCategory), timeLimit: timeLimitForCustomer(), size: CGSize(width: 50, height: 50)) {
            self.logger.info("Customer left")
            self.loseGame()
        }
        
        if addCustomer(newCustomer) {
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
