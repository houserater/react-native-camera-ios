/**
 * RNCamera Examples React Native App
 * https://github.com/houserater/react-native-camera-ios
 */

import React from 'react';
import {
  AppRegistry,
  StyleSheet,
  Button,
  View
} from 'react-native';

import BasicCamera from "./BasicCamera";
import CustomCamera from "./CustomCamera";

export default class RNCameraExamples extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      basicCameraVisible: false
    };
  }
  _setCameraVisible(type, visible) {
    let field = `${type}CameraVisible`;
    this.setState({
      [field]: visible
    });
  }
  render() {
    return (
      <View style={styles.container}>
        <Button
          onPress={() => this._setCameraVisible('basic', true)}
          title="Launch Basic Camera"
        />

        <Button
            onPress={() => this._setCameraVisible('custom', true)}
            title="Launch Custom Camera"
        />

        <BasicCamera
            visible={this.state.basicCameraVisible}
            onCancel={() => this._setCameraVisible('basic', false)}
            onCapture={() => this._setCameraVisible('basic', false)}
        />

        <CustomCamera
            visible={this.state.customCameraVisible}
            onCapture={() => this._setCameraVisible('custom', false)}
        />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'white',
  },
});

AppRegistry.registerComponent('RNCameraExamples', () => RNCameraExamples);
