# Photo Classifier
A general photo classifier that uses iOS' MLCore and MobileNet model to classify any image. The app does this on a live video. Following is a demo video recorded on an iPad.

![demo](demo/demo.gif)

## Goals 

The goal of the project was to explore CoreML and the Vision framework. The app makes use of the following iOS frameworks.

1. **CoreML:** The app uses _CoreML_ to load the [MobileNet](https://developer.apple.com/machine-learning/models/) framework to classify images.
2. **Vision:** The app uses the vision framework to take an image and classify the most prominent object in it by making use of the MobileNet model.
3. **AVFoundation:** The app pulls video frames directly from the camera to process them and also displays a live preview of the camera.
4. **Combine:** As frames coming from the camera is a continuous process so publisher-subscriber (reactive stream) makes a perfect fit. Also the frames speed is way higher than what we need to process so app uses throttling (back pressure handling).

## Requirements
The app requires camera so it will not work on a simulator. Anyone interested in trying it has to run it on a device.