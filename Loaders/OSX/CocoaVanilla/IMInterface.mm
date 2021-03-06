// IMInterface.mm: text service context interface
// This implementation loads CocoaVanilla (OVLoader.bundle)
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

#include <Cocoa/Cocoa.h>
#include <Carbon/Carbon.h>
#include "IMInterface.h"
#include "CVLoader.h"

// #define OVDEBUG
#include <OpenVanilla/OVUtility.h>

CVLoader *loader=NULL;

int IMInitialize(MenuRef mnu)
{
    if (loader)
		return 1;
    
    loader = new CVLoader;    
    
	if (!loader)
		return 0;
	
    return loader->init(mnu);
}

int IMContextOpen(IMContext* c)
{
    return (c->data=loader->newContext()) ? 1 : 0;
}

void IMContextClose(IMContext* c)
{
    if (c->data)
		delete (CVContext*)(c->data);
}

void IMContextActivate(IMContext* c)
{
    if (c->data)
		((CVContext*)(c->data))->activate(c->buf);
}

void IMContextDeactivate(IMContext* c)
{
    if (c->data)
		((CVContext*)(c->data))->deactivate();
}

void IMContextFix(IMContext* c)
{
    if (c->data)
		((CVContext*)(c->data))->fix();
}

int IMContextEvent(IMContext* c, char charcode, unsigned int modifiers)
{
    if (c->data)
		return ((CVContext*)(c->data))->event(charcode, modifiers);
    return 0;
}

void IMMenuHandler(IMContext *c, unsigned int cmd)
{
    loader->menuHandler(cmd);
}

