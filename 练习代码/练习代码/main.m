//
//  main.m
//  练习代码
//
//  Created by 张裕阳 on 2023/2/19.
//

#import <Foundation/Foundation.h>

@interface Fraction : NSObject
-(void) print;
-(void) setNumerator: (int) n;
-(void) setDenominator: (int) d;
@end



@implementation Fraction
{
    int numerator;
    int denominator;
}

-(void) print {
    NSLog(@"%i/%i", numerator, denominator);
}

-(void) setNumerator: (int) n {
    numerator = n;
}

-(void) setDenominator: (int) d {
    denominator = d;
}
@end


int main(int argc, const char *argv[]) {
    //第一个示例程序
    @autoreleasepool {
        Fraction *myFraction;
        myFraction = [Fraction alloc];
        myFraction = [myFraction init];
        
        [myFraction setNumerator: 1];
        [myFraction setDenominator: 3];
        
        NSLog(@"the value of my fraction is:");
        [myFraction print];
//        int result, value1, value2;
//        value1 = 87;
//        value2 = 15;
//        result = value1 - value2;
//        NSLog(@"the subtraction of %i and %i is %i", value1, value2, result);
    }
    return 0;
}
