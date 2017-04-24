//
//  TDDIYWebViewDatasource.m
//  Cmall
//
//  Created by Moyun on 2017/2/15.
//  Copyright © 2017年 Moyun. All rights reserved.
//

#import "TDDIYWebViewDatasource.h"
#import "UIAlertController+CMCreate.h"
#import "UIImageView+CMUIActivityIndicatorForSDWebImage.h"
#import "NSURL+CMAddImageBaseURL.h"
#import "TDDIYWebView.h"
#import "TDDIYWebViewModel.h"

@implementation TDDIYWebViewDatasource

#pragma mark - UICollectionView Datasource & Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.webVC.viewModel numberOfRowsWithTag:collectionView.tag];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    
    switch (collectionView.tag) {
        case TDDIYTagTypeDesignGroupList:
        {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TDSubSkuCell class]) forIndexPath:indexPath];
            /*设计分组列表
             hasGroup Long 否 是否需要对商品列表进行分组过滤
             groupType Int 是 分组的类型
             groupCode String 是 分组的code
             groupName String 是 分组的名称
             groupValue Double 是 分组的值
             groupInfoVos String  是 商品列表 List<TudeSdkGoodsInfoVo>
             */
            NSDictionary *dict = self.webVC.viewModel.designGroupList[indexPath.item];
            BOOL selected = (self.webVC.viewModel.designGroupSelected > -1 && self.webVC.viewModel.designGroupSelected == indexPath.item);
            NSString *groupName = [dict[@"groupName"] isEqual:[NSNull null]]?@"":dict[@"groupName"];
            [(TDSubSkuCell*)cell configCellWithName:groupName selected:selected];
            break;
        }
        case TDDIYTagTypeDesignList:
        {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TDDesignSKUCell class]) forIndexPath:indexPath];
            /*设计列表
             productId Long 是 产品id 如：100
             modelClassId Long 是 模型设计id
             goodsId Int 是 商品id 如：1
             goodsName String 是 商品名称 如：女士文化衫
             goodsImagePath String 是 商品图片 如：/img/xx.jpg
             goodsType Int 是 商品类型 2自营商品
             */
            NSDictionary *dict = self.webVC.viewModel.designList[indexPath.item];
            BOOL selected = (self.webVC.viewModel.designSelected > -1 && self.webVC.viewModel.designSelected == indexPath.item);
            NSString *goodsImagePath = [dict[@"goodsImagePath"] isEqual:[NSNull null]]?@"":dict[@"goodsImagePath"];
            [(TDDesignSKUCell*)cell configCellWithImageUrl:goodsImagePath selected:selected];
            
            break;
        }
        case TDDIYTagTypeDetailImgsList:
        {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CMImageViewCell class]) forIndexPath:indexPath];
            [(CMImageViewCell*)cell configCellWithImageUrl:self.webVC.viewModel.detailImageUrlString?:@""];
            break;
        }
        default:
            break;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.webVC.diyWebView.menuButton.isCollapsed) {
        [self.webVC.diyWebView.menuButton dismissButtons];
    }
    switch (collectionView.tag) {
            /*设计分组列表
             hasGroup Long 否 是否需要对商品列表进行分组过滤
             groupType Int 是 分组的类型
             groupCode String 是 分组的code
             groupName String 是 分组的名称
             groupValue Double 是 分组的值
             groupInfoVos String  是 商品列表 List<TudeSdkGoodsInfoVo>
             */
        case TDDIYTagTypeDesignGroupList:
        {
            if (self.webVC.viewModel.designGroupSelected >= 0 && self.webVC.viewModel.designGroupSelected == indexPath.item) {
                return;
            }
            self.webVC.viewModel.designGroupSelected = indexPath.item >= 0 && indexPath.item < self.webVC.viewModel.designGroupList.count ? indexPath.item : -1;
            NSDictionary *dict = self.webVC.viewModel.designGroupList[indexPath.item];
            
            self.webVC.viewModel.designList = [dict[@"goodsInfoVos"] isEqual:[NSNull null]]?@"":dict[@"goodsInfoVos"];
            self.webVC.viewModel.designSelected = 0;
            [self.webVC.viewModel switchModelGoodsDesign:[self.webVC.viewModel.designList firstObject]];
            
            [collectionView reloadData];
            [collectionView selectItemAtIndexPath:indexPath animated:true scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
            break;
        }
        case TDDIYTagTypeDesignList:
        {
            if (self.webVC.viewModel.designSelected >= 0 && self.webVC.viewModel.designSelected == indexPath.item) {
                return;
            }
            self.webVC.viewModel.designSelected = indexPath.item >= 0 && indexPath.item < self.webVC.viewModel.designList.count ? indexPath.item : -1;
            
            NSDictionary *dict = self.webVC.viewModel.designList[indexPath.item];
            [self.webVC.viewModel switchModelGoodsDesign:dict];
            
            [collectionView reloadData];
            [collectionView selectItemAtIndexPath:indexPath animated:true scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
            break;
        }
        case TDDIYTagTypeDetailImgsList:
        {
            
        }
        default:
            break;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self.webVC.viewModel sizeForItemWithTag:collectionView.tag];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    if (![[webView.URL host] containsString:@".cmall.com"]) {
        [UIAlertController alertWithTitle:@"温馨提示" message:@"你当前访问的网址非法" cancelTitle:@"好哒" inViewCtl:self.webVC];
    }
    decisionHandler([[webView.URL host] containsString:@".cmall.com"]);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    DLog(@"webViewDidFinishLoad");
    [self.webVC.viewModel loadedProcess];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    DLog(@"==error:%@",error);
    [self.webVC loadWebViewFailed];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    DLog(@"==error:%@",error);
    [self.webVC loadWebViewFailed];
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    DLog(@"将要白屏了，这里reload一下webView");
}

@end
