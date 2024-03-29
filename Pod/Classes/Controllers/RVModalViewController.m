//
//  RVModalViewController.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-27.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "Rover.h"
#import "RVModalViewController.h"
#import "RVNetworkingManager.h"
#import "RVVisitProject.h"
#import "RVCardDeckView.h"
#import "RVCardView.h"
#import "RVCardProject.h"
#import "RVCloseButton.h"
#import "RVModalView.h"
#import "RVImageEffects.h"

@interface RVModalViewController () <RVModalViewDelegate, RVCardDeckViewDelegate, RVCardDeckViewDataSourceDelegate>

@property (strong, nonatomic) RVModalView *view;
@property (strong, nonatomic) RVVisit *visit;
@property (readonly, nonatomic) NSArray *cards;

@end

@implementation RVModalViewController
{
    NSArray *_cards;
}

@dynamic view;

#pragma mark - Properties

- (void)setVisit:(RVVisit *)visit {
    _visit = visit;
    _cards = nil;
    [self.view.cardDeck reloadData];
}

- (void)setCardSet:(ModalViewCardSet)cardSet {
    _cardSet = cardSet;
    _cards = nil;
}

- (NSArray *)cards {
    if (_cards) {
        return _cards;
    }
    
    if (self.cardSet == ModalViewCardSetSaved) {
        _cards = self.visit.savedCards;
    } else if (self.cardSet == ModalViewCardSetUnread) {
        _cards = self.visit.unreadCards;
    } else {
        _cards = self.visit.cards;
    }
    
    return _cards;
}

#pragma mark - Initialization

- (id)init {
    if (self = [super init]) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.cardSet = ModalViewCardSetAll;
    }
    return self;
}

- (void)loadView {
    self.view = [[RVModalView alloc] initWithFrame:UIScreen.mainScreen.applicationFrame];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createBlur];
    
    self.view.delegate = self;
    self.view.cardDeck.delegate = self;
    self.view.cardDeck.dataSource = self;
    
    self.visit = [[Rover shared] currentVisit];
    [self.view.cardDeck reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.view.cardDeck animateIn:nil];
}

/* Create a blurred snapshot of current screen
 */
- (void)createBlur {
    UIViewController* rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    UIView *view = rootViewController.view;
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIColor *tintColor = [UIColor colorWithWhite:0.0 alpha:0.15];
    image = [RVImageEffects applyBlurWithRadius:3 tintColor:tintColor saturationDeltaFactor:1 maskImage:nil toImage:image];
    
    self.view.background.image = image;
}

#pragma mark - RVModalViewDelegate

- (void)modalViewBackgroundPressed:(RVModalView *)modalView {
    if (self.delegate) {
        [self.delegate modalViewControllerDidFinish:self];
    }
}

#pragma mark - RVCardDeckViewDelegate

- (void)cardDeckDidPressBackground:(RVCardDeckView *)cardDeck {
    [self.delegate modalViewControllerDidFinish:self];
}

- (void)cardDeck:(RVCardDeckView *)cardDeck didSwipeCard:(RVCardView *)cardView {
    NSUInteger idx = [cardDeck indexForCardView:cardView];
    RVCard *card = [self.cards objectAtIndex:idx];
    
    if ([self.delegate respondsToSelector:@selector(modalViewController:didSwipeCard:)]) {
        [self.delegate modalViewController:self didSwipeCard:card];
    }
    
    if (idx == [self.cards count] - 1 && self.delegate) {
        [self.delegate modalViewControllerDidFinish:self];
    }
}

- (void)cardDeck:(RVCardDeckView *)cardDeck didShowCard:(RVCardView *)cardView {
    NSUInteger idx = [self.view.cardDeck indexForCardView:cardView];
    RVCard *card = [self.cards objectAtIndex:idx];
    card.isUnread = NO;
    card.viewedAt = [NSDate date];
    [card save:nil failure:nil];
    
    if ([self.delegate respondsToSelector:@selector(modalViewController:didDisplayCard:)]) {
        [self.delegate modalViewController:self didDisplayCard:card];
    }
}

- (void)cardDeck:(RVCardDeckView *)cardDeck didLikeCard:(RVCardView *)cardView {
    NSUInteger idx = [self.view.cardDeck indexForCardView:cardView];
    RVCard *card = [self.cards objectAtIndex:idx];
    card.likedAt = [NSDate date];
    card.discardedAt = nil;
    [card save:nil failure:nil];
}

- (void)cardDeck:(RVCardDeckView *)cardDeck didUnlikeCard:(RVCardView *)cardView {
    NSUInteger idx = [self.view.cardDeck indexForCardView:cardView];
    RVCard *card = [self.cards objectAtIndex:idx];
    card.likedAt = nil;
    [card save:nil failure:nil];
}

- (void)cardDeck:(RVCardDeckView *)cardDeck didDiscardCard:(RVCardView *)cardView {
    NSUInteger idx = [self.view.cardDeck indexForCardView:cardView];
    RVCard *card = [self.cards objectAtIndex:idx];
    card.likedAt = nil;
    card.discardedAt = [NSDate date];
    [card save:nil failure:nil];
}

#pragma mark - RVCardDeckViewDataSourceDelegate

- (NSUInteger)numberOfItemsInDeck:(RVCardDeckView *)cardDeck {
    return self.cards.count;
}

- (RVCardView *)cardDeck:(RVCardDeckView *)cardDeck cardViewForItemAtIndex:(NSUInteger)index {
    RVCard *card = [self.cards objectAtIndex:index];
    RVCardView  *cardView = [cardDeck createCard];
    cardView.title = card.title;
    cardView.shortDescription = card.shortDescription;
    cardView.longDescription = card.longDescription;
    cardView.imageURL = card.imageURL;
    cardView.backgroundColor = card.primaryBackgroundColor;
    cardView.fontColor = card.primaryFontColor;
    cardView.secondaryBackgroundColor = card.secondaryBackgroundColor;
    cardView.secondaryFontColor = card.secondaryFontColor;
    cardView.liked = card.likedAt != nil;
    cardView.discarded = card.discardedAt != nil;
    return cardView;
}

@end
