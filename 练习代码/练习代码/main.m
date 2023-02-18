//
//  main.m
//  练习代码
//
//  Created by 张裕阳 on 2023/2/19.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        int result, value1, value2;
        value1 = 87;
        value2 = 15;
        result = value1 - value2;
        NSLog(@"the subtraction of %i and %i is %i", value1, value2, result);
    }
    return 0;
}
