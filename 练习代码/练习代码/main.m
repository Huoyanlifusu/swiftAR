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


@interface Calculator : NSObject
//累加方法
-(void) setAccumulator: (int) a;
-(void) clear;
-(double) accumulator;
//算术方法
-(void) add: (double) value;
-(void) subtract: (double) value;
-(void) multiply: (double) value;
-(void) divide: (double) value;
@end

@implementation Calculator
{
    double accumulator;
}
-(void) setAccumulator: (int) a{
    accumulator = a;
}
-(void) clear {
    accumulator = 0;
}
-(double) accumulator {
    return accumulator;
}
-(void) add: (double) value {
    accumulator += value;
}
-(void) subtract: (double) value {
    accumulator -= value;
}
-(void) multiply: (double) value {
    accumulator *= value;
}
-(void) divide: (double) value {
    accumulator /= value;
}

@end


int main(int argc, const char *argv[]) {
    //第一个示例程序
    @autoreleasepool {
        Calculator *myCalculator = [[Calculator alloc] init];
        [myCalculator setAccumulator: 100];
        [myCalculator add: 30.0];
        NSLog(@"The result is %g", [myCalculator accumulator]);
        
        
        
        
//        Fraction *myFraction;
//        myFraction = [Fraction alloc];
//        myFraction = [myFraction init];
//
//        [myFraction setNumerator: 1];
//        [myFraction setDenominator: 3];
//
//        NSLog(@"the value of my fraction is:");
//        [myFraction print];
        
        
        
//        int result, value1, value2;
//        value1 = 87;
//        value2 = 15;
//        result = value1 - value2;
//        NSLog(@"the subtraction of %i and %i is %i", value1, value2, result);
    }
    return 0;
}
