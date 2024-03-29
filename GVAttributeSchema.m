/*************************************************************************
 * Copyright (c) 2011 AT&T Intellectual Property 
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors: Details at http://www.graphviz.org/
 *************************************************************************/

#import "GVAttributeSchema.h"

static NSXMLDocument *_attributes;
static NSTextFieldCell *_stringCell;
static NSComboBoxCell *_enumCell;

@implementation GVAttributeSchema

+ (void)initialize
{
	_attributes = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"attributes" ofType:@"xml"]] options:0 error:nil];

	NSFont *smallFont = [NSFont labelFontOfSize:[NSFont systemFontSizeForControlSize:NSControlSizeSmall]];

	_stringCell = [[NSTextFieldCell alloc] init];
	_stringCell.controlSize = NSControlSizeSmall;
	_stringCell.drawsBackground = NO;
	_stringCell.editable = YES;
	_stringCell.enabled = YES;
	_stringCell.font = smallFont;

	_enumCell = [[NSComboBoxCell alloc] init];
	_enumCell.bezeled = NO;
	_enumCell.buttonBordered = NO;
	_enumCell.completes = YES;
	_enumCell.controlSize = NSControlSizeSmall;
	_enumCell.drawsBackground = NO;
	_enumCell.editable = YES;
	_enumCell.enabled = YES;
	_enumCell.font = smallFont;
	_enumCell.hasVerticalScroller = NO;
}

+ (NSArray *)attributeSchemasWithComponent:(NSString *)component
{
	NSMutableArray *attributeSchemas = [NSMutableArray array];
	for (NSXMLElement *element in [_attributes nodesForXPath:[NSString stringWithFormat:@"/xsd:schema/xsd:complexType[@name='%@']/xsd:attribute", component] error:nil])
		[attributeSchemas addObject:[[GVAttributeSchema alloc] initWithXMLElement:element]];
	return attributeSchemas;
}

- (instancetype)initWithXMLElement:(NSXMLElement *)element
{
	if (self = [super init])
		_element = element;
	return self;
}

- (NSString *)name
{
	return [_element attributeForName:@"ref"].stringValue;
}

- (NSCell *)cell
{
	NSCell *typeCell = _stringCell;

	/* determine which cell to return */
	NSString *type = [_attributes nodesForXPath:[NSString stringWithFormat:@"/xsd:schema/xsd:attribute[@name='%@']/@type[1]", self.name] error:nil].lastObject.stringValue;
	if (type && ![type hasPrefix:@"xsd:"]) {
		NSXMLElement *simpleType = [_attributes nodesForXPath:[NSString stringWithFormat:@"/xsd:schema/xsd:simpleType[@name='%@'][1]", type] error:nil].lastObject;
		NSArray *enumerations = [simpleType nodesForXPath:@"xsd:restriction/xsd:enumeration" error:nil];
		if (enumerations.count) {
			[_enumCell removeAllItems];
			for (NSXMLElement *enumeration in enumerations)
				[_enumCell addItemWithObjectValue:[enumeration attributeForName: @"value"].stringValue];
			typeCell = _enumCell;
		}
	}

	/* determine the default value */
	NSString *defaultValue = [_element attributeForName:@"default"].stringValue;
	if ([typeCell respondsToSelector:@selector(setPlaceholderString:)])
		[typeCell performSelector:@selector(setPlaceholderString:) withObject:defaultValue];
	return typeCell;
}

- (NSString *)documentation
{
	return [_attributes nodesForXPath:[NSString stringWithFormat:@"/xsd:schema/xsd:attribute[@name='%@']/xsd:annotation/xsd:documentation[1]", self.name] error:nil].lastObject.XMLString;
}

@end
