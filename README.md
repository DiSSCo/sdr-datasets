# Specimen Data Refinery datasets 

Specimen Data Refinery training datasets - see:

- [Pinned insects dataset](https://github.com/DiSSCo/SDR/issues/2)
- [Microscope slides dataset](https://github.com/DiSSCo/SDR/issues/3)
- [Herbarium sheet dataset](https://github.com/DiSSCo/SDR/issues/7)


## JSON Structure of HTR, DLA and NER Datasets

These datasets were initially produced by [Teklia](https://teklia.com).

### Common

Every JSON file shares a common payload:

- `dataset_id` is the Arkindex element ID of the overall dataset
- `page`
  - `id` is the Arkindex element ID of the current page (holding annotations)
  - `name` is the page name
  - `rotation_angle` is the angle in degrees of the image (in most cases it's 0 - no rotation)
- `folder`
  - `id` is the Arkindex element ID of the direct parent folder of the current page
  - `name` is the folder name
- `image`
  - `id` is the Arkindex image ID
  - `iiif_base_url` is the IIIF image ID, used to build other image urls (crops, thumbnails, ...)
  - `url` is the IIIF full image URL (may be slowish to load depending on resolution)

#### Example

```json
{
    "dataset_id": "503d7e35-a2cd-4d98-a272-930519fc29b5",
    "folder": {
        "id": "6395c279-8d51-4fc2-b77e-eb65a3f9fcd0",
        "name": "Kew"
    },
    "image": {
        "id": "d12ca238-30f0-45cb-a5cd-ac26d9b26bda",
        "iiif_base_url": "https://europe-gamma.iiif.teklia.com/iiif/2/synthesys%2Fmlb-data%2Fsynthesys%2Fherbarium_2%2FK000234241.jpg",
        "url": "https://europe-gamma.iiif.teklia.com/iiif/2/synthesys%2Fmlb-data%2Fsynthesys%2Fherbarium_2%2FK000234241.jpg/full/full/0/default.jpg"
    },
    "page": {
        "id": "02c02000-22f3-44b0-b82b-4851a4b65c66",
        "name": "K000234241",
        "rotation_angle": 0
    }
}
```

### DLA

The **DLA** files hold an extra `polygons` list of coordinates for detected lines or regions, sorted by element types (text line, ...).

```json
    ...
    "polygons": {
        "text_line": [
            [
                [
                    1219,
                    3668
                ],
                [
                    1219,
                    3738
                ],
                [
                    2208,
                    3738
                ],
                [
                    2208,
                    3668
                ],
                [
                    1219,
                    3668
                ]
            ]
        ]
    ]
    ...
```

### HTR

The **HTR** files hold an extra `transcriptions` key which is a list of dictionaries:
- `polygon` is a list of points describing the zone being transcribed,
- `rotation_angle` is the angle in degrees of the element on the image (in most cases it's 0 - no rotation)
- `transcription` is the full text transcription of this polygon
- `worker_version_id` is the Arkindex ID of the worker used to produce that transcription (`null` means it's been created by a human)

```json
    ...
    "transcriptions": [
        {
            "polygon": [
                [
                    1219,
                    3668
                ],
                [
                    1219,
                    3738
                ],
                [
                    2208,
                    3738
                ],
                [
                    2208,
                    3668
                ],
                [
                    1219,
                    3668
                ]
            ],
            "rotation_angle": 0,
            "transcription": "ROYAL BOTANIC GARDENS KEW",
            "worker_version": "3314991d-c1b3-4a8b-9074-eacefa832fac"
        }
    ]
    ...
```

### NER

The **NER** files hold an extra `named_entities` key which is a list of dictionaries:
- `tags` is the list of entities in BIO format
- `worker_version_id` is the Arkindex ID of the worker used to produce these entities (`null` means it's been created by a human)


```json
    ...
    "named_entities": [
        {
            "tags": "Mr B-person_name\nGedeh I-person_name\n? O\nIdera O",
            "worker_version_id": null
        },
        {
            "tags": "NHMUK011249955 B-identifier",
            "worker_version_id": null
        }
    ]
    ...
```
