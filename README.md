# React Native Camera iOS

*Native iOS Camera ImagePicker w/ cameraOverlayView support.*

## Getting Started

Install React Native Camera iOS:

```bash
$ yarn add react-native-camera-ios
```

Then link it to your project:

```bash
$ react-native link
```

## Usage

The `RNCamera` component that is exported by this module is based on
[`<Modal/>`][modal] from the React Native team.

```js
import React from 'react';
import {
    View,
    Button,
    StyleSheet
} from 'react-native';
import RNCamera from 'react-native-camera-ios';

const styles = StyleSheet.create({
    overlayRight: {
        position: 'absolute',
        right: 0,
        top: 0,
        bottom: 0,
        width: 80,
        alignItems: 'center'
    }
});
class CameraModal extends React.Component {
    onCapture({ image }) {
        // Fields available:
        // `image.path`, `image.width`, `image.height`

        this.props.onCapture(image.path);
    }
    render() {
        return (
            <RNCamera
                ref={(r) => this.camera = r}
                {...this.props}
                onCapture={(event) => this.onCapture(event)}
            >
                <View
                    style={styles.overlayRight}
                >
                    <Button
                        onPress={() => this.camera.capture()}
                        color="white"
                        title="Capture"
                    />
                </View>
            </RNCamera>
        );
    }
}
```

### Functions

#### capture()

This function causes the camera to begin taking a photo (i.e. activating flash,
adjusting exposure), and will later call the `onCapture()` event with the new
image information on disk.

This function should not be called again until the `onCapture()` callback has
been triggered.

### Props

#### visible: Boolean

Whether the modal should be visible on the screen. Defaults to `false`.

#### animationType: String

The animation style for opening the camera modal. Can be `none`, `slide`, or
`fade`. Defaults to `slide`.

#### onCapture(event): Function

Event function when the camera button or `capture()` function has been
triggered, and the file has been completely written to disk. This function will
be called with the event structure below:

```js
{
    image: {
        path: String,
        width: Number,
        height: Number
    }
}
```

#### onCancel(): Function

Event function when the Cancel button has been pressed on the default iOS camera
screen. When children views are defined, this function cannot be called because
the system replaces the standard view (including the Cancel button) with custom
views.

## Notes

- This module is currently in initial stages of development, and it **not
recommended** for large-scale use
- This module is currently only tested on iPad devices and the iPad Simulator

## License

[MIT][license]


[modal]: http://facebook.github.io/react-native/docs/modal.html
[license]: https://github.com/houserater/react-native-camera-ios/blob/master/LICENSE
