//
//  TemplateStorage.swift
//  SourceSyncSDK
//
//  Created by ayman badawy on 23/03/2025.
//
struct TemplateStorage {
    
    static let defaultPreviewTemplate: [String: Any] =
    [
        "template": [
            [
                "type": "text",
                "content": "A very basic preview template",
                "attributes": [
                    "font": "system",
                    "size": "md",
                    "color": "#EEEEEE",
                    "weight": "bold"
                ]
            ],
            [
                "type": "text",
                "content": "Click to see details",
                "attributes": [
                    "font": "system",
                    "size": "md",
                    "color": "#FFFFFF",
                    "alignment": "center",
                    "style": "italic"
                ]
            ]
        ]
    ]
    
    static let defaultDetailTemplate: [String: Any] =
    [
        "template": [
            [
                "type": "text",
                "content": "Full Content View",
                "attributes": [
                    "font": "system",
                    "size": "lg",
                    "color": "#FFFFFF",
                    "weight": "bold",
                    "alignment": "center"
                ]
            ],
            [
                "type": "image",
                "content": "https://storage.googleapis.com/source-uploads-production/uploads/user-media/bbb_image1_aee8ad527d.png",
                "attributes": [
                    "size": [
                        "width": "60%",
                        "height": "40%"
                    ],
                    "contentMode": "scaletofill",
                    "alignment": "center"
                ]
            ],
            [
                "type": "text",
                "content": "This is the main content that appears when the preview is clicked.",
                "attributes": [
                    "font": "system",
                    "size": "xl",
                    "color": "#FFFFFF",
                    "alignment": "center"
                ]
            ]
        ]
    ]
    
}
