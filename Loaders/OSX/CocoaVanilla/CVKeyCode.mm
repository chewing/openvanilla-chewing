// CVKeyCode.mm: CocoaVanilla implementation of OVKeyCode
//
// Copyright (c) 2004-2008 The OpenVanilla Project (http://openvanilla.org)
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. Neither the name of OpenVanilla nor the names of its contributors
//    may be used to endorse or promote products derived from this software
//    without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#include <ctype.h>
#include "CVKeyCode.h"
#include "NSStringExtension.h"

CVKeyCode::CVKeyCode(char charcode, UInt32 modifiers)
{
	m = modifiers;
	c = charcode;
	
	// translate keycode
	switch (c) {
		case 3:		// Mac's very confusing "enter" key
			c = ovkReturn;
			break;
	}
}

CVKeyCode::CVKeyCode(const char *charcode, const char *modifiers)
{
	init (charcode, modifiers);
}

CVKeyCode::CVKeyCode(NSString *s)
{
	NSArray *a = [s splitBySpaceWithQuote];
	if ([a count] < 2)
		init([s UTF8String], "");
	else
		init([[a objectAtIndex:0] UTF8String], [[a objectAtIndex:1] UTF8String]);
}

void CVKeyCode::init(const char *charcode, const char *modifiers) {
    c = 0;
    if (strlen(charcode) == 1) {
        c = toupper(*charcode);
    }
    else {
        #define KMAP(x,y)  if(!strcasecmp(charcode, x)) c = y
        KMAP("esc", ovkEsc);
        else KMAP("space", ovkSpace);
        else KMAP("delete", ovkDelete);
        else KMAP("backspace", ovkBackspace);
        else KMAP("up", ovkUp);
        else KMAP("down", ovkDown);
        else KMAP("left", ovkLeft);
        else KMAP("right", ovkRight);
        else KMAP("home", ovkHome);
        else KMAP("end", ovkEnd);
        else KMAP("pageup", ovkPageUp);
        else KMAP("pagedown", ovkPageDown);
        else KMAP("tab", ovkTab);
        #undef KMAP
    }
	m = 0;
	
	for (size_t i = 0; i < strlen(modifiers); i++) {
		switch (toupper(modifiers[i])) {
			case 'M': m |= cmdKey; break;
			case 'O': m |= optionKey; break;
			case 'C': m |= controlKey; break;
			case 'S': m |= shiftKey; break;
		}
	}
}

BOOL CVKeyCode::equalToKey(CVKeyCode* k, BOOL ignorecase)
{
	if (ignorecase) {
		if (toupper(code()) != toupper(k->code())) 
			return NO;
	}
	else {
		if (code() != k->code())
			return NO;
	}

	if ((isShift() == k->isShift()) &&
	    (isCtrl() == k->isCtrl()) &&
		(isOpt() == k->isOpt()) &&
		(isCommand() == k->isCommand()))
		return YES;

	return NO;
}

UInt8 CVKeyCode::convertToMenuModifier()
{
	UInt8 mm = 0;
	
	if (isShift()) mm |= kMenuShiftModifier;
	if (isCtrl()) mm |= kMenuControlModifier;
	if (isOpt()) mm |= kMenuOptionModifier;
	if (!isCommand()) mm |= kMenuNoCommandModifier;
	return mm;
}

bool CVKeyCode::isShift() 
{
    if (m & (shiftKey | rightShiftKey))
		return true;
    return false;
}

bool CVKeyCode::isCtrl()
{
    if (m & (controlKey | rightControlKey))
		return true;
    return false;
}

bool CVKeyCode::isAlt()
{
    if (m & (optionKey | rightOptionKey))
		return true;
    return false;
}

bool CVKeyCode::isCommand()
{
    if (m & cmdKey)
		return true;
    return false;
}

bool CVKeyCode::isCapslock()
{
    if (m & (alphaLock | kEventKeyModifierNumLockMask))
		return true; 
//  if (m & alphaLock) return 1; 
    return false;
}

NSArray *CVKeyCode::getKeyList()
{
    NSMutableArray *ma = [NSMutableArray array];
    #define KMAP(x)     [ma addObject:x]
    KMAP(@"esc");
    KMAP(@"space");
    KMAP(@"delete");
    KMAP(@"backspace");
    KMAP(@"up");
    KMAP(@"down");
    KMAP(@"left");
    KMAP(@"right");
    KMAP(@"home");
    KMAP(@"end");
    KMAP(@"pageup");
    KMAP(@"pagedown");
    KMAP(@"tab");
    #undef KMAP
    char *s = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!\"#$%&'()*+,-./:;< = >?@[\\]^_`";
    for (size_t i = 0; i < strlen(s); i++) {
		unichar c = s[i];
		[ma addObject:[NSString stringWithCharacters:&c length:1]];
    }

    return ma;
}

NSString *CVKeyCode::getKeyCodeString()
{
	#define KMAP(x,y)  if(c == y) return x
    KMAP(@"esc", ovkEsc);
    else KMAP(@"space", ovkSpace);
    else KMAP(@"delete", ovkDelete);
    else KMAP(@"backspace", ovkBackspace);
    else KMAP(@"up", ovkUp);
    else KMAP(@"down", ovkDown);
    else KMAP(@"left", ovkLeft);
    else KMAP(@"right", ovkRight);
    else KMAP(@"home", ovkHome);
    else KMAP(@"end", ovkEnd);
    else KMAP(@"pageup", ovkPageUp);
    else KMAP(@"pagedown", ovkPageDown);
    else KMAP(@"tab", ovkTab);
	#undef KMAP
	unichar c = code();
	return [NSString stringWithCharacters:&c length:1];
}

NSString *CVKeyCode::getKeyIconString()
{
	NSString *string = getKeyCodeString();
	#define KMAP(x,y)  if([string isEqualToString:x]) return [NSString stringWithUTF8String:y]
	KMAP(@"space", "Space");
	else KMAP(@"delete", "⌦");
	else KMAP(@"backspace", "⌫");
	else KMAP(@"up", "↑");
	else KMAP(@"down", "↓");
	else KMAP(@"left", "←");
	else KMAP(@"right", "→");
	else KMAP(@"home", "↖");
	else KMAP(@"end", "↘");
	else KMAP(@"pageup", "⇞");
	else KMAP(@"pagedown", "⇟");
	else KMAP(@"tab", "⇥");	
	#undef KMAP
	return string;
}

NSString *CVKeyCode::getModifierIconString()
{ 
	NSMutableString *s = [NSMutableString string];

//	#define APPEND(x) [s appendString:[NSString stringWithUTF8String:x]];
//  if (isCommand()) APPEND("⌘")
//  if (isOpt()) APPEND("⌥")
//  if (isCtrl()) APPEND("⌃")
//  if (isShift()) APPEND("⇧")

	unichar ch;
	#define APPEND(x)  { ch = x; [s appendString:[NSString stringWithCharacters:&ch length:1]];}
    if (isCommand()) APPEND(kCommandUnicode)
    if (isOpt()) APPEND(kOptionUnicode)
    if (isCtrl()) APPEND(kControlUnicode)
    if (isShift()) APPEND(kShiftUnicode)		
	#undef APPEND	
	return s;
}

NSString *CVKeyCode::getModifierString()
{
	NSMutableString *s = [NSMutableString string];
	
	#define APPEND(x) [s appendString:x];
    if (isCommand()) APPEND(@"m")
    if (isOpt()) APPEND(@"o")
    if (isCtrl()) APPEND(@"c")
	if (isShift()) APPEND(@"s")
	#undef APPEND
	return s;	
}