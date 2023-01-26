//
//  MathUtilities.swift
//  artest
//
//  Created by 张裕阳 on 2022/9/27.
//

import Foundation
import simd
import SceneKit
import ARKit
import Accelerate

//azumith radian in XOY plane
func azumith(from direction: simd_float3) -> Float {
    return asin(direction.z)
}

//elevation angle
func elevation(from direction: simd_float3) -> Float {
    return atan2(direction.x, direction.y)
}

//turn radian to degree
func radianToDegrees(radian: Float) -> Float {
    return radian * 57.2957795
}

func coordinateAlignment(eularAngle: simd_float3, direction: simd_float3, distance: Float) -> simd_float3 {
    //先将NI摄像头坐标系 转换为 AR摄像头坐标系
    let dx: Float = -1 * direction.y * distance //单位 米
    let dy: Float = direction.x * distance
    let dz: Float = direction.z * distance
    let theta_x: Float = eularAngle.x //单位 弧度数
    let theta_y: Float = eularAngle.y
    let theta_z: Float = eularAngle.z
    
    //再利用欧拉角和旋转矩阵将AR摄像头坐标系数据 转换为 AR世界坐标系数据
    
    //y-x-z顺序外旋公式
    //world坐标 - ar local camera坐标
    
    let e11: Float = cos(theta_y)*cos(theta_z) + sin(theta_x)*sin(theta_y)*sin(theta_z)
    let e12: Float = sin(theta_y)*sin(theta_x)*cos(theta_z) - cos(theta_y)*sin(theta_z)
    let e13: Float = sin(theta_y)*cos(theta_x)
    
    let e21: Float = cos(theta_x) * sin(theta_z)
    let e22: Float = cos(theta_x) * cos(theta_z)
    let e23: Float = -1 * sin(theta_x)

    let e31: Float = cos(theta_y)*sin(theta_x)*sin(theta_z) - sin(theta_y)*cos(theta_z)
    let e32: Float = sin(theta_y)*sin(theta_z) + cos(theta_y)*sin(theta_x)*cos(theta_z)
    let e33: Float = cos(theta_y)*cos(theta_x)

    //矩阵向量顺序 列一 列二 列三
    let matrix: simd_float3x3 = simd_float3x3(simd_float3(e11, e21, e31),
                                              simd_float3(e12, e22, e32),
                                              simd_float3(e13, e23, e33))
    
    //因此ar cam向量 - world向量 只需要求上述矩阵的逆即可
    let inverseMatrix = inverse(matrix: matrix)
    
    let dXw: Float = inverseMatrix.columns.0.x * dx + inverseMatrix.columns.1.x * dy + inverseMatrix.columns.2.x * dz
    let dYw: Float = inverseMatrix.columns.0.y * dx + inverseMatrix.columns.1.y * dy + inverseMatrix.columns.2.y * dz
    let dZw: Float = inverseMatrix.columns.0.z * dx + inverseMatrix.columns.1.z * dy + inverseMatrix.columns.2.z * dz
    
    
    return simd_float3(dXw, dYw, dZw)
}

func inverse(matrix: simd_float3x3) -> simd_float3x3 {
    return matrix.inverse
}


extension FloatingPoint {
    var degreeToRadians: Self { self * .pi / 180}
    var radiansToDegrees: Self { self * 180 / .pi }
}

extension SCNVector3 {
    func convertToSIMD3() -> simd_float3 {
        return simd_float3(x, y, z)
    }
}

func position(from vector: simd_float4) -> simd_float3 {
    return simd_float3(vector.x, vector.y, vector.z)
}

func translation(from matrix: simd_float4x4, with position_diff: simd_float3) -> simd_float4x4 {
    var newmatrix = matrix
    newmatrix.columns.3.x += position_diff.x
    newmatrix.columns.3.y += position_diff.y
    newmatrix.columns.3.z += position_diff.z
    return newmatrix
}

func correctPose(with peerEuler: simd_float4, using myEuler: simd_float3) -> simd_float4x4 {
    let x_diff:Float = myEuler.x - peerEuler.x
    let y_diff:Float = myEuler.y - peerEuler.y
    let z_diff:Float = myEuler.z - peerEuler.z
    print("\(y_diff)")
    var newPose = simd_float4x4(simd_float4(1,0,0,0),
                                simd_float4(0,1,0,0),
                                simd_float4(0,0,1,0),
                                simd_float4(0,0,0,1))
    if abs(x_diff) > 0.1 {
        newPose = simd_float4x4(SCNMatrix4MakeRotation(x_diff, 1, 0, 0))
    }
    if abs(y_diff) > 0.1 {
        newPose = simd_float4x4(SCNMatrix4MakeRotation(y_diff, 0, 1, 0))
    }
    if abs(z_diff) > 0.1 {
        newPose = simd_float4x4(SCNMatrix4MakeRotation(z_diff, 0, 0, 1))
    }
    print("\(newPose)")
    return newPose
}
