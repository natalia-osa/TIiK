//
//  TIiKAppDelegate.h
//  TIiK
//
//  Created by Natalia Osiecka on 19.03.2013.
//  Copyright (c) 2013 Politechnika Poznańska. All rights reserved.
//

/** Teoria informacji i kodowania *** Idzikowska ***
 
 
 ### Informacje ogólne o przedmiocie ###
 -- oceny na bazie tego, co zrobiliśmy
 -- może być sprawdzian np. w domu zrobić metodę x-x a na zajęciach zakodować metodą x-x
 -- dowolne środowisko i język programowania, nie korzystamy z bibliotek
 -- jeden wspólny program na wszystkie laborki (różne moduły)
 -- case sensitive
 
 
 ### Laboratoria 1 ###
 1. Przygotuj 3 pliki, przy czym każdy plik powinien zawierać przynajmniej 6000 znaków:
    1.1. Litery w języku polskim,
    1.2. Informatyczny w języku polskim,
    1.3. Dowolny w j. angielskim.
 2. Napisz program, który czyta plik tekstowy i wypisuje wszystkie występujące w nim znaki oraz wyznacza częstość ich występowania.
 3. Program mam wyznaczać też entropię binarną obliczonego rozkładu prawdopodobieństwa i wyznaczać ilość informacji w poszczególnych znakach.
 4. Wykonaj program dla trzech przygotowanych plików i porównaj wyniki.
 
 Wzory:
 H = suma P(si)I(si) -- entropia
 I(si) = log2(1/P(si)) -- miara informacji
 
 ### Laboratoria 2 ###
 1. Implementacja kompresji metodą Hoffmana (statyczna)
    1.1. Kodowanie - w porównaniu z miarą entropii widać jak dobre jest kodowanie
    1.2. Dekodowanie - potrzebna informacja jakie znaki jak są kodowane
 
 Wzory:
 http://www.algorytm.org/algorytmy-kompresji/kody-huffmana.html
 
 
 ### Labrotoria 3 ###
 1. Kodowanie arytmetyczne
 
 Wzory:
 
 **/

#import <UIKit/UIKit.h>

@interface TIiKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
