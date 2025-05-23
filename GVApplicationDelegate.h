/*************************************************************************
 * Copyright (c) 2011 AT&T Intellectual Property 
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors: Details at http://www.graphviz.org/
 *************************************************************************/

@import AppKit;

@class GVAttributeInspectorController;

@interface GVApplicationDelegate : NSObject<NSApplicationDelegate>
{
	GVAttributeInspectorController *_attributeInspectorController;
	BOOL _applicationStarted;
}

- (IBAction)showAttributeInspector:(id)sender;

- (BOOL)applicationOpenUntitledFile:(NSApplication *)application;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;

@end
