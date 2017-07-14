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
        top: 0, bottom: 0, right: 0,
        width: 80,
        alignItems: 'center',
        justifyContent: 'center'
    }
});
export default class CustomCamera extends React.Component {
    static propTypes = {
        ...RNCamera.propTypes
    };

    render() {
        return (
            <RNCamera
                ref={(r) => this.camera = r}
                {...this.props}
            >
                <View
                    style={styles.overlayRight}
                >
                    <Button
                        onPress={() => this.camera.capture()}
                        title="Take"
                    />
                </View>
            </RNCamera>
        );
    }
}
