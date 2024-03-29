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

@interface GVAttributeSchema : NSObject
{
	NSXMLElement *_element;
}

@property(readonly) NSString *name;
@property(readonly) NSCell *cell;
@property(readonly) NSString *documentation;

+ (NSArray *)attributeSchemasWithComponent:(NSString *)component;
- (instancetype)initWithXMLElement:(NSXMLElement *)element;

@end
