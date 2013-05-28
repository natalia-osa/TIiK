//
//  CRCHelper.m
//  TIiK
//
//  Created by Natalia Osiecka on 28.05.2013.
//  Copyright (c) 2013 Politechnika Poznańska. All rights reserved.
//

/** http://pl.wikipedia.org/wiki/Cykliczny_kod_nadmiarowy
 Algorytm postępowania w celu obliczenia 3-bitowego CRC jest następujący:
 1. dodajemy do ciągu danych 3 wyzerowane bity,
 2. w linii poniżej wpisujemy 4-bitowy dzielnik CRC,
 3. jeżeli mamy 0 nad najstarszą pozycją dzielnika, to przesuwamy dzielnik w prawo o jedną pozycję, aż do napotkania 1,
 4. wykonujemy operację XOR pomiędzy bitami dzielnika i odpowiednimi bitami ciągu danych, uwzględniając dopisane 3 bity
 5. wynik zapisujemy w nowej linii poniżej,
 6. jeżeli liczba bitów danych jest większa lub równa 4, przechodzimy do kroku 2,
 7. 3 najmłodsze bity stanowią szukane CRC, czyli cykliczny kod nadmiarowy
 **/

#import "CRCHelper.h"
#import "StringHelper.h"

@implementation CRCHelper

#warning translate polish instructions into english

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)crcData {
    // wejście
    NSString *plainText = @"11010011101110";
    // crc
    NSString *crcDivider = @"1011";
    
    // calculate crc
    NSString *crcString = [self crcWithInputString:plainText crcCode:crcDivider checkCorrectness:NO];
    // validate if crc is correct
    NSString *validationString = [self crcWithInputString:[NSString stringWithFormat:@"%@%@", plainText, crcString] crcCode:crcDivider checkCorrectness:YES];
    
    // wyświetl wynik
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Result (%@)", nil), validationString]
                                                        message:[NSString stringWithFormat:@"%@", crcString]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
    [alertView show];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)crcWithInputString:(NSString*)plainText crcCode:(NSString*)crcDivider checkCorrectness:(BOOL)checkCorrectness {
    // oblicz n
    int n = crcDivider.length -1;
    
    if (checkCorrectness) {
        /// 1. przy sprawdzaniu zostawiamy dane jak są
    } else {
        /// 1. dodajemy do ciągu danych n wyzerowanych bitów
        for (int i = n; i > 0; i--) {
            plainText = [NSString stringWithFormat:@"%@0", plainText];
        }
    }
    
    // konwertuj stringi do tablic charów
    unichar *textBuffer = calloc([plainText length], sizeof(unichar));
    [plainText getCharacters:textBuffer];
    unichar *crcBuffer = calloc([crcDivider length], sizeof(unichar));
    [crcDivider getCharacters:crcBuffer];
    
    // główny algorytm CRC
    for (int i = 0; i < (plainText.length - n); i++) {
        /// 2. jeżeli mamy 0 nad najstarszą pozycją dzielnika, to przesuwamy dzielnik w prawo o jedną pozycję, aż do napotkania 1,
        if (textBuffer[i] == '1') {
            /// 3. wykonujemy operację XOR pomiędzy bitami dzielnika i odpowiednimi bitami ciągu danych
            for (int j = 0; j < crcDivider.length; j++) {
                if (crcBuffer[j] == textBuffer[i+j]) {
                    textBuffer[i+j] = '0';
                } else {
                    textBuffer[i+j] = '1';
                }
            }
        }
    }
    
    NSString *crc = @"";
    if (checkCorrectness) {
        /// 6. przy sprawdzaniu jeżeli n ostatnich to 0, wyświetl że jest poprawny
        for (int i = 0; i <= n; i++) {
            if (textBuffer[[plainText length]-i] == '1') {
                crc = NSLocalizedString(@"CRC Validation failed", nil);
            }
        }
        if ([crc isEqualToString:@""]) {
            crc = NSLocalizedString(@"CRC Validation succeeded", nil);
        }
    } else {
        /// 6. n najmłodszych bitów stanowi szukane CRC, czyli cykliczny kod nadmiarowy
        for (int i = 0; i <= n; i++) {
            crc = [NSString stringWithFormat:@"%@%c", crc, textBuffer[[plainText length]-i]];
        }
    }
    
    // uwolnij pamięć
    free(textBuffer);
    free(crcBuffer);
    
    return crc;
}


@end
