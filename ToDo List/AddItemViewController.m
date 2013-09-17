//
//  AddItemViewController.m
//  ToDo List
//
//  Created by Super Student on 9/17/13.
//  Copyright (c) 2013 CS-360_Students. All rights reserved.
//

#import "AddItemViewController.h"

@interface AddItemViewController ()

@end

@implementation AddItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//This method will be called when the add button is pressed. It is supposed to save the data that was entered for the new task.
//  And it will save the data into a SQL database.
- (IBAction)addItem:(id)sender
{
    
}

//This is called when the Task textfield is done entering text into it. The keyboard's return button and tapping outside of the
//  screen will trigger this.
- (IBAction)taskEntered:(UITextField *)textField {
    [textField resignFirstResponder];
}

@end
