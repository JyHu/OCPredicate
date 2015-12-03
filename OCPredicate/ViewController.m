//
//  ViewController.m
//  OCPredicate
//
//  Created by 胡金友 on 15/5/14.
//  Copyright (c) 2015年 胡金友. All rights reserved.
//

#import "ViewController.h"
#import "REControl.h"

#define RGBA(R, G, B, A) ([NSColor colorWithRed:(R/255.0) green:(G/255.0) blue:(B/255.0) alpha:A])

@interface ViewController()<NSTableViewDelegate, NSTableViewDataSource, NSTextViewDelegate>

@property (unsafe_unretained) IBOutlet NSTextView *sourceTextView;

@property (unsafe_unretained) IBOutlet NSTextView *regularTextView;

@property (weak) IBOutlet NSTableView *resultListTable;

@property (unsafe_unretained) IBOutlet NSTextView *resultDetailTextView;

@property (weak) IBOutlet NSTableView *sampleListTable;

@property (weak) IBOutlet NSButton *matchButton;

- (IBAction)matchRExpression:(NSButton *)sender;

@property (weak) IBOutlet NSTextField *matchResultsCountLabel;

@property (retain, nonatomic) NSArray *sampleREArray;

@property (retain, nonatomic) NSMutableArray *matchesResultArray;

@property (assign, nonatomic) NSInteger maxColumnsInMathes;

@property (retain, nonatomic) NSString *matchREREString;

@property (unsafe_unretained) IBOutlet NSTextView *reSamplesTextView;

@property (assign, nonatomic) NSInteger selectedSampleRow;

@end

@implementation ViewController

@synthesize sampleREArray = _sampleREArray;

@synthesize matchesResultArray = _matchesResultArray;

@synthesize maxColumnsInMathes = _maxColumnsInMathes;

@synthesize matchREREString = _matchREREString;

@synthesize selectedSampleRow = _selectedSampleRow;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _selectedSampleRow = -1;
    
    NSString *pp = [[NSBundle mainBundle] pathForResource:@"SampleRE"
                                                   ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:pp];
    
    _sampleREArray = [dict objectForKey:@"regularExpression"];
    _matchREREString = [dict objectForKey:@"matchRE"];
    
    NSString *rp = [[NSBundle mainBundle] pathForResource:@"RECharacters"
                                                   ofType:@"txt"];
    NSString *rpString = [[NSString alloc] initWithContentsOfFile:rp
                                                         encoding:NSUTF8StringEncoding
                                                            error:nil];
    self.reSamplesTextView.string = rpString;
    self.reSamplesTextView.font = [NSFont systemFontOfSize:8];
    
    [self attributeSampleRECharacters];
    
    self.regularTextView.delegate = self;
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

}

#pragma mark - table delegate and dataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (tableView.tag == 101)
    {
        return _sampleREArray.count;
    }
    return _matchesResultArray.count;
}

- (id)tableView:(NSTableView *)tableView
                objectValueForTableColumn:(NSTableColumn *)tableColumn
                row:(NSInteger)row
{
    if (tableView.tag == 101)
    {
        NSDictionary *tD = [_sampleREArray objectAtIndex:row];
        NSString *rn = [tD objectForKey:@"rn"];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:rn];
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:_selectedSampleRow == row ? [NSColor blackColor] : [NSColor brownColor]
                                 range:NSMakeRange(0, rn.length)];
        return attributedString;
    }
    
    if ([tableColumn.identifier isEqualToString:@"id"])
    {
        return [NSString stringWithFormat:@"%@",@(row)];
    }
    
    NSString *title;
    
    for (NSInteger i = 0; i < _maxColumnsInMathes; i++)
    {
        if ([[NSString stringWithFormat:@"column%@",@(i)] isEqualToString:tableColumn.identifier])
        {
            NSArray *tArr = [self.matchesResultArray objectAtIndex:row];
            
            if (i < tArr.count)
            {
                title = [tArr objectAtIndex:i];
            }
            else
            {
                title = @"";
            }
            
            break;
        }
    }
    
    return title;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *table = (NSTableView *)notification.object;
    
    if (table.tag == 100)
    {
        NSInteger sColumn = [_resultListTable selectedColumn];
        NSInteger sRow = [_resultListTable selectedRow];
        
        NSMutableString *resString = [[NSMutableString alloc] initWithString:@"\n"];
        
        if (sColumn >= 0)
        {
            // selected title
            
            for (NSInteger i = 0; i < _matchesResultArray.count; i ++)
            {
                NSArray *tArr = [_matchesResultArray objectAtIndex:i];
                
                if (sColumn == 0)
                {
                    for (NSInteger j = 0; j<tArr.count; j++)
                    {
                        [resString appendString:[tArr objectAtIndex:j]];
                        if (tArr.count > 1)
                        {
                            [resString appendString:@"\n. . . . . . . . . . . . . . . . . . . . . . . . . . . \n\n"];
                        }
                        else
                        {
                            [resString appendString:@"\n\n"];
                        }
                    }
                    [resString appendString:@"* * * * * * * * * * * * * * * * * * * * \n"];
                }
                else
                {
                    if (sColumn - 1 < tArr.count)
                    {
                        [resString appendString:[tArr objectAtIndex:(sColumn - 1)]];
                    }
                    else
                    {
                        [resString appendString:@"NO MATCHES AT THIS ROW"];
                    }
                    
                    [resString appendString:@"\n. . . . . . . . . . . . . . . . . . . . . . . . . . . \n\n"];
                }
            }
        }
        else
        {
            // selected row
            
            if (sRow < _matchesResultArray.count)
            {
                NSArray *tempArr = [_matchesResultArray objectAtIndex:sRow];
                
                for (NSInteger i = 0; i<tempArr.count; i++)
                {
                    [resString appendString:[tempArr objectAtIndex:i]];
                    
                    [resString appendString:@"\n. . . . . . . . . . . . . . . . . . . . . . . . . . . \n\n"];
                }
            }
        }
        
        self.resultDetailTextView.string = resString;
    }
    else
    {
        NSInteger selRow = self.sampleListTable.selectedRow;
        
        NSDictionary *dict = [_sampleREArray objectAtIndex:_sampleListTable.selectedRow];
        self.regularTextView.string = [dict objectForKey:@"re"];
        self.title = [dict objectForKey:@"rn"];
        
        NSMutableIndexSet *sets = [NSMutableIndexSet indexSet];
        [sets addIndex:selRow];
        if (_selectedSampleRow != -1)
        {
            [sets addIndex:_selectedSampleRow];
        }
        [self.sampleListTable reloadDataForRowIndexes:sets
                                        columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        
        _selectedSampleRow = selRow;
    }
}

#pragma mark - button click methods

- (IBAction)matchRExpression:(NSButton *)sender
{
    NSString *sourceString = self.sourceTextView.string;
    NSString *reString = self.regularTextView.string;
    
    BOOL sourceTextIsNil = ([sourceString stringByReplacingOccurrencesOfString:@" "
                                                                    withString:@""].length == 0);
    BOOL reIsNil = ([reString stringByReplacingOccurrencesOfString:@" "
                                                        withString:@""].length == 0);
    
    if (!(sourceTextIsNil || reIsNil))
    {
        _maxColumnsInMathes = 0;
        
        [self.matchesResultArray removeAllObjects];
        
        NSRegularExpression *rege = [[NSRegularExpression alloc] initWithPattern:reString
                                                                         options:[REControl shareControl].reOptions
                                                                           error:nil];
        NSArray *matches = [rege matchesInString:sourceString
                                         options:[REControl shareControl].matchOptions
                                           range:NSMakeRange(0, sourceString.length)];
        
        self.matchResultsCountLabel.stringValue = [NSString stringWithFormat:@"%@",@(matches.count)];
        
        for (NSTextCheckingResult *res in matches)
        {
            NSInteger rangesOfMatch = res.numberOfRanges;
            
            _maxColumnsInMathes = _maxColumnsInMathes > rangesOfMatch ? _maxColumnsInMathes : rangesOfMatch;
            
            NSMutableArray *tArr = [[NSMutableArray alloc] init];
            
            for (int i = [REControl shareControl].matchGroupZero ? 0 : 1; i < rangesOfMatch; i++)
            {
                NSRange range = [res rangeAtIndex:i];
                
                if (!(range.location > sourceString.length || range.location + range.length > sourceString.length))
                {
                    [tArr addObject:[sourceString substringWithRange:range]];
                }
                else
                {
                    [tArr addObject:@""];
                }
            }
            
            [self.matchesResultArray addObject:tArr];
        }
    }
    else
    {
        self.matchResultsCountLabel.stringValue = @"";
        [self.matchesResultArray removeAllObjects];
    }
    [self reloadTable];
}

#pragma mark - help methods

- (void)reloadTable
{
    for (NSTableColumn *column in [_resultListTable.tableColumns copy])
    {
        [_resultListTable removeTableColumn:column];
    }
    
    self.resultDetailTextView.string = @"";
    
    NSRect rect = _resultListTable.frame;
    CGFloat perWidth = (rect.size.width - 50)/ (_maxColumnsInMathes * 1.0);
    
    for (int i = 0; i <= _maxColumnsInMathes; i ++)
    {
        NSString *identifier = (i == 0 ? @"id" : [NSString stringWithFormat:@"column%@",@(i - 1)]);
        NSString *title = (i == 0 ? @"id" : [NSString stringWithFormat:@"R%@",@(i - 1)]);
        
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:identifier];
        column.width = (i == 0 ? 30 : perWidth);
        column.title = title;
        column.editable = (i != 0);
        [_resultListTable addTableColumn:column];
    }
    
    [_resultListTable reloadData];
}

#pragma mark - getter methods

- (NSMutableArray *)matchesResultArray
{
    if (!_matchesResultArray)
    {
        _matchesResultArray = [[NSMutableArray alloc] init];
    }
    
    return _matchesResultArray;
}

#pragma mark - textView delegate

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRanges:(NSArray *)affectedRanges
                                        replacementStrings:(NSArray *)replacementStrings
{
    if ([replacementStrings.firstObject isEqualToString:@"“"] || [replacementStrings.firstObject isEqualToString:@"”"])
    {
        return NO;
    }
    return YES;
}

#pragma mark - help methods

- (void)attributeRegularExpression
{
    NSString *reString = self.regularTextView.string;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:reString];
    
    NSRegularExpression *rere = [[NSRegularExpression alloc] initWithPattern:_matchREREString
                                                                     options:NSRegularExpressionCaseInsensitive
                                                                       error:nil];
    NSArray *matches = [rere matchesInString:reString options:0 range:NSMakeRange(0, reString.length)];
    
    for (NSTextCheckingResult *match in matches)
    {
        NSRange range = match.range;
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[NSColor redColor]
                                 range:range];
    }
    [[self.regularTextView textStorage] setAttributedString:attributedString];
}

- (void)attributeSampleRECharacters
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.reSamplesTextView.string];
    
    NSRegularExpression *reExp = [[NSRegularExpression alloc] initWithPattern:@"(.+)\\s+-\\s+(.+)"
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:nil];
    NSArray *reMatches = [reExp matchesInString:self.reSamplesTextView.string
                                        options:0
                                          range:NSMakeRange(0, self.reSamplesTextView.string.length)];
    
    for (NSTextCheckingResult *match in reMatches)
    {
        NSRange reRange = [match rangeAtIndex:1];
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[NSColor redColor] range:reRange];
        NSRange tpRange = [match rangeAtIndex:2];
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[NSColor brownColor] range:tpRange];
    }
    
    reExp = nil;
    reMatches = nil;
    
    reExp = [[NSRegularExpression alloc] initWithPattern:@"-{2,}.*-{2,}>"
                                                 options:NSRegularExpressionAnchorsMatchLines
                                                   error:nil];
    reMatches = [reExp matchesInString:self.reSamplesTextView.string
                               options:0
                                 range:NSMakeRange(0, self.reSamplesTextView.string.length)];
    for (NSTextCheckingResult *match in reMatches)
    {
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[NSColor purpleColor] range:match.range];
    }
    
    reExp = nil;
    reMatches = nil;
    
    reExp = [[NSRegularExpression alloc] initWithPattern:@"\\([\\u4e00-\\u9fa5]+.*[^-].*.*\\)"
                                                 options:NSRegularExpressionCaseInsensitive
                                                   error:nil];
    reMatches = [reExp matchesInString:self.reSamplesTextView.string
                               options:0
                                 range:NSMakeRange(0, self.reSamplesTextView.string.length)];
    for (NSTextCheckingResult *match in reMatches)
    {
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[NSColor grayColor] range:match.range];
    }
    
    reExp = nil;
    reMatches = nil;
    
    [self.reSamplesTextView.textStorage setAttributedString:attributedString];
}

@end
