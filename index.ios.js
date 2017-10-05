/**
 * Copyright (c) 2017, HouseRater LLC.
 * All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @providesModule react-native-camera-ios
 */

import PropTypes from 'prop-types';

import React from "react";
import {
    NativeModules,
    requireNativeComponent,
    StyleSheet,
    I18nManager,
    View
} from "react-native";
import AppContainer from "AppContainer";

const RNCameraHostViewManager = NativeModules.RNCameraHostViewManager;

export default class RNCamera extends React.Component {
    static propTypes = {
        visible: PropTypes.bool,
        animationType: PropTypes.oneOf([ 'none', 'fade', 'slide' ]),
        cameraDevice: PropTypes.oneOf([ 'front', 'rear' ]),
        cameraFlashMode: PropTypes.oneOf([ 'off', 'auto', 'on' ]),

        onCancel: PropTypes.func,
        onCapture: PropTypes.func,
    };
    static defaultProps = {
        visible: false,
        animationType: 'slide',
        cameraFlashMode: 'off'
    };
    static contextTypes = {
        rootTag: PropTypes.number,
    };

    capture() {
        RNCameraHostViewManager.capture();
    }

    static checkFlashAvailable(callback, cameraDevice = 'rear') {
        RNCameraHostViewManager.checkFlashAvailableWithCameraDevice(cameraDevice, callback);
    }

    _onCapture(event) {
        const { onCapture } = this.props;

        const { image, width, height } = event.nativeEvent;

        let captureEvent = {
            image: {
                path: image,
                width,
                height
            }
        };

        onCapture(captureEvent);
    }

    render() {
        const { visible, children, ...otherProps } = this.props;

        if (!visible) {
            return null;
        }

        const innerChildren = children && (__DEV__ ? (
            <AppContainer rootTag={this.context.rootTag}>
                {children}
            </AppContainer>
        ) : children);

        return (
            <RNCameraHostView
                {...otherProps}
                onCapture={(event) => this._onCapture(event)}
                style={styles.modal}
                onStartShouldSetResponder={() => true}
            >
                {innerChildren && (
                    <View
                        style={styles.container}
                    >
                        {innerChildren}
                    </View>
                )}
            </RNCameraHostView>
        )
    }
}

const RNCameraHostView = requireNativeComponent('RNCameraHostView', RNCamera);

const side = I18nManager.isRTL ? 'right' : 'left';
const styles = StyleSheet.create({
    modal: {
        position: 'absolute',
    },
    container: {
        position: 'absolute',
        [side] : 0,
        top: 0,
    }
});
