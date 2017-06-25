//
//  BaseChart.m
//  HSCharts
//
//  Created by 黄舜 on 17/6/8.
//  Copyright © 2017年 I really is a farmer. All rights reserved.
//

#import "BaseChart.h"

#define GGLazyGetMethod(type, attribute)            \
- (type *)attribute                                 \
{                                                   \
    if (!_##attribute) {                            \
        _##attribute = [[type alloc] init];         \
    }                                               \
    return _##attribute;                            \
}

#define Layer_Key    [NSString stringWithFormat:@"%zd", tag]

@interface BaseChart ()

@property (nonatomic) NSMutableDictionary * lineLayerDictionary;

@property (nonatomic) NSMutableDictionary * pieLayerDictionary;

@property (nonatomic, strong) NSMutableArray <GGShapeCanvas *> * visibleLayers;      ///< 显示的图层

@property (nonatomic, strong) NSMutableArray <GGShapeCanvas *> * idleLayers;         ///< 闲置的图层

@end

@implementation BaseChart

/**
 * 绘制图表(子类重写)
 */
- (void)drawChart
{
    [self.idleLayers addObjectsFromArray:self.visibleLayers];
    
    [self.visibleLayers enumerateObjectsUsingBlock:^(GGShapeCanvas * obj, NSUInteger idx, BOOL * stop) {
        
        [obj removeFromSuperlayer];
    }];
    
    [self.visibleLayers removeAllObjects];
}

/**
 * 取图层视图大小与Chart一致
 */
- (GGShapeCanvas *)getGGCanvasEqualFrame
{
    GGShapeCanvas * shape = [self makeOrGetShapeCanvas];
    shape.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self.layer addSublayer:shape];
    [self.visibleLayers addObject:shape];
    return shape;
}

/**
 * 取图层视图大小为正方形
 */
- (GGShapeCanvas *)getGGCanvasSquareFrame
{
    CGFloat width = self.frame.size.width > self.frame.size.height ? self.frame.size.height : self.frame.size.width;
    GGShapeCanvas * shape = [self makeOrGetShapeCanvas];
    shape.frame = CGRectMake(0, 0, width, width);
    [self.layer addSublayer:shape];
    [self.visibleLayers addObject:shape];
    return shape;
}

/**
 * 获取图层
 */
- (GGShapeCanvas *)makeOrGetShapeCanvas
{
    GGShapeCanvas * shape = [self.idleLayers firstObject];
    
    if (shape == nil) {
        
        shape = [[GGShapeCanvas alloc] init];
    }
    else {
    
        [self.idleLayers removeObject:shape];
    }
    
    return shape;
}

#pragma mark - Old 

- (GGCanvas *)getCanvasWithTag:(NSInteger)tag
{
    GGCanvas * layer = [self.lineLayerDictionary objectForKey:Layer_Key];
    
    if (!layer) {
        
        layer = [[GGCanvas alloc] init];
        layer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self.layer addSublayer:layer];
        [self.lineLayerDictionary setObject:layer forKey:Layer_Key];
    }
        
    return layer;
}

- (GGShapeCanvas *)getShapeWithTag:(NSInteger)tag
{
    GGShapeCanvas * layer = [self.lineLayerDictionary objectForKey:Layer_Key];
    
    if (!layer) {
        
        layer = [[GGShapeCanvas alloc] init];
        layer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self.layer addSublayer:layer];
        [self.lineLayerDictionary setObject:layer forKey:Layer_Key];
    }
    
    return layer;
}

- (GGShapeCanvas *)getPieWithTag:(NSInteger)tag
{
    GGShapeCanvas * layer = [self.pieLayerDictionary objectForKey:Layer_Key];
    
    if (!layer) {
        
        CGFloat width = self.frame.size.width > self.frame.size.height ? self.frame.size.height : self.frame.size.width;
        CGFloat x = (self.frame.size.width - width) / 2;
        CGFloat y = (self.frame.size.height - width) / 2;
        
        layer = [[GGShapeCanvas alloc] init];
        layer.frame = CGRectMake(x, y, width, width);
        layer.anchorPoint = CGPointMake(0.5, 0.5);
        [self.layer addSublayer:layer];
        [self.pieLayerDictionary setObject:layer forKey:Layer_Key];
    }
    
    return layer;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self.lineLayerDictionary enumerateKeysAndObjectsUsingBlock:^(id key, CALayer * obj, BOOL * stop) {
        
        obj.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }];
    
    [self.pieLayerDictionary enumerateKeysAndObjectsUsingBlock:^(id key, CALayer * obj, BOOL * stop) {
        
        CGFloat width = self.frame.size.width > self.frame.size.height ? self.frame.size.height : self.frame.size.width;
        CGFloat x = (self.frame.size.width - width) / 2;
        CGFloat y = (self.frame.size.height - width) / 2;
        
        obj.frame = CGRectMake(x, y, width, width);
    }];
}

#pragma mark - Lazy

GGLazyGetMethod(NSMutableDictionary, lineLayerDictionary);

GGLazyGetMethod(NSMutableDictionary, pieLayerDictionary);

GGLazyGetMethod(NSMutableArray, visibleLayers);

GGLazyGetMethod(NSMutableArray, idleLayers);

@end
