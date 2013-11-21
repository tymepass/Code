//
//  ContactViewController.m
//  Timepass
//
//  Created by Urvesh Patel on 6/29/2012.
//  Copyright (c) 2012 Regius IT Solutions Pvt. Ltd. All rights reserved.
//

#import "ContactViewController.h"

@implementation ContactViewController
@synthesize arrContact,tableview;
//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    arrContact=[[NSMutableArray alloc] init];
       // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark -Other Methods
-(void)LoadContact
{
    [arrContact removeAllObjects];
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef addressBookData = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    CFIndex count = CFArrayGetCount(addressBookData);
    
    NSMutableArray *contactsArray = [NSMutableArray new];
    
    for (CFIndex idx = 0; idx < count; idx++) {
        ABRecordRef person = CFArrayGetValueAtIndex(addressBookData, idx);
        
        NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        
        /** Fetch Email addres */
        NSString *emailID =  [NSString stringWithFormat:@""];
        ABMultiValueRef emails = (ABMultiValueRef) ABRecordCopyValue(person, kABPersonEmailProperty);
        for (CFIndex i=0; i < ABMultiValueGetCount(emails); i++) {
            
            //[emailID release];
            emailID = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, 0);  
            //NSLog(@"emailid:%@",emailID);
        }
        
        if (firstName && emailID) {
            // NSDictionary *dict =[NSDictionary dictionaryWithObject:firstName forKey:@"name"];
            
            NSDictionary *dict=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:firstName,emailID, nil] forKeys:[NSArray arrayWithObjects:@"name",@"email", nil]];
            // [NSDictionary dictionaryWithObject:firstName ForKey:@"name"];
            [contactsArray addObject:dict];
        }
        
    }
    [arrContact addObjectsFromArray:contactsArray];
    NSLog(@"contact array %@",contactsArray);
    CFRelease(addressBook);
    CFRelease(addressBookData);
    [tableview reloadData];

}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [arrContact count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text=[[arrContact objectAtIndex:indexPath.row]objectForKey:@"name"];
    cell.detailTextLabel.text=[[arrContact objectAtIndex:indexPath.row]objectForKey:@"email"];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
