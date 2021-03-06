/*

File:KeymanInputController.m

Abstract: Keyman input controller class.

Version: 1.0

Disclaimer: IMPORTANT:  This Apple software is supplied to you by 
Apple Inc. ("Apple") in consideration of your agreement to the
following terms, and your use, installation, modification or
redistribution of this Apple software constitutes acceptance of these
terms.  If you do not agree with these terms, please do not use,
install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software. 
Neither the name, trademarks, service marks or logos of Apple Inc. 
may be used to endorse or promote products derived from the Apple
Software without specific prior written permission from Apple.  Except
as expressly stated in this notice, no other rights or licenses, express
or implied, are granted by Apple herein, including but not limited to
any patent rights that may be infringed by your derivative works or by
other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2007 Apple Inc. All Rights Reserved.

*/
#import "KeymanInputController.h"


@implementation KeymanInputController

/*
Implement one of the three ways to receive input from the client. 
Here are the three approaches:
                 
                 1.  Support keybinding.  
                        In this approach the system takes each keydown and trys to map the keydown to an action method that the input method has implemented.  If an action is found the system calls didCommandBySelector:client:.  If no action method is found inputText:client: is called.  An input method choosing this approach should implement
                        -(BOOL)inputText:(NSString*)string client:(id)sender;
                        -(BOOL)didCommandBySelector:(SEL)aSelector client:(id)sender;
                        
                2. Receive all key events without the keybinding, but do "unpack" the relevant text data.
                        Key events are broken down into the Unicodes, the key code that generated them, and modifier flags.  This data is then sent to the input method's inputText:key:modifiers:client: method.  For this approach implement:
                        -(BOOL)inputText:(NSString*)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender;
                        
                3. Receive events directly from the Text Services Manager as NSEvent objects.  For this approach implement:
                        -(BOOL)handleEvent:(NSEvent*)event client:(id)sender;
*/

/*!
	@method     
    @abstract   Receive incoming text.
	@discussion This method receives key board input from the client application.  The method receives the key input as an NSString. The string will have been created from the keydown event by the InputMethodKit.
*/
-(BOOL)inputText:(NSString*)string client:(id)sender
{
    //Return YES to indicate the the key input was received and dealt with.  Key processing will not continue in that case.  In
	//other words the system will not deliver a key down event to the application.
	//Returning NO means the original key down will be passed on to the client.
	NSLog(@"%@", string);
	return NO;
}

const int NUM_RULES = 8;

unichar rules[NUM_RULES][3] = {
	{'a','o',0xe5},
	{'A','O',0xc5},
	
	{'o','e',0xf6},
	{'O','E',0xd6},
	
	{'a','e',0xe4},
	{'A','E',0xc4},

	{'e', 0x27, 0xe9},
	{'e', 0x60, 0xe8}
};

-(BOOL)inputText:(NSString*)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender
{
	NSAssert([string length] == 1, @"More than one character in %@", string);
	unichar c = [string characterAtIndex:0];
	
	NSLog(@"prev: %C c: %C", _prev, c);
	
	// go through hoops to get buffer position
	[sender setMarkedText:@"" selectionRange:NSMakeRange(0,0) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
	NSUInteger pos = [sender markedRange].location;
	NSLog(@"pos=%lu", pos);

	for (int i=0; i<NUM_RULES; i++)
	{
		if (pos != _prev_pos+1)
			continue;
		
		if (_prev == rules[i][0] && c == rules[i][1]) {
			[sender insertText:[NSString stringWithCharacters:(rules[i]+2) length:1] replacementRange:NSMakeRange(pos-1, 1)];
			_prev = rules[i][2];
			return YES;
		}
		
		if (_prev == rules[i][2] && c == rules[i][1]) {
			NSLog(@"Bailing out");
			[sender insertText:[NSString stringWithCharacters:rules[i] length:2] replacementRange:NSMakeRange(pos-1, 1)];
			_prev = rules[i][1];
			return YES;
		}
	}
	
	_prev = c;
	_prev_pos = pos;
	
	return NO;
}

@end
