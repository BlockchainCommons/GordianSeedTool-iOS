//
//  SSKRPrintPage.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 4/8/21.
//

import SwiftUI
import URKit
import URUI

struct SSKRShareCoupon: Identifiable {
    let id = UUID()
    let ur: UR
    let bytewords: String
    let seed: ModelSeed
    let groupIndex: Int
    let shareThreshold: Int
    let sharesCount: Int
    let shareIndex: Int
    
    var bytewordsBody: String {
        bytewords.split(separator: " ").dropLast(4).joined(separator: " ")
    }
    
    var bytewordsChecksum: String {
        bytewords.split(separator: " ").suffix(4).joined(separator: " ")
    }
}

struct SSKRPrintPage: View {
    let pageIndex: Int
    let pageCount: Int
    let groupThreshold: Int
    let groupsCount: Int
    let seed: ModelSeed
    let coupons: [SSKRShareCoupon]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header()
            hSpacer()
            hDivider()
            ForEach(coupons) { coupon in
                couponView(coupon)
            }
            Spacer()
        }
        .font(.system(size: 12))
        .padding(0.25 * pointsPerInch)
    }
    
    func header() -> some View {
        HStack(alignment: .top) {
            ModelObjectIdentity(model: .constant(seed), allowLongPressCopy: false, generateLifeHashAsync: false)
                .frame(height: 64)
            VStack(alignment: .trailing) {
                pageNumber()
                groupsSummary()
            }
        }
    }
    
    func pageNumber() -> some View {
        Text("Page \(pageIndex + 1) of \(pageCount)")
    }
    
    func groupsSummary() -> some View {
        Text("Groups: \(groupThreshold) of \(groupsCount)")
    }
    
    func couponView(_ coupon: SSKRShareCoupon) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                receipt(coupon: coupon)
                    .frame(width: 1.5 * pointsPerInch)
                vSpacer()
                vDivider()
                vSpacer()
                certificate(coupon: coupon)
            }
            hSpacer()
            hDivider()
        }
        .frame(height: 2.0 * pointsPerInch)
        .padding([.top], 0.25 * pointsPerInch)
    }
    
    func receipt(coupon: SSKRShareCoupon) -> some View {
        VStack(alignment: .leading) {
            Text("Group: \(coupon.groupIndex + 1)")
            Text("Shares: \(coupon.shareThreshold) of \(coupon.sharesCount)")
            Spacer()
                .frame(height: 10)
            Text("Share: \(coupon.shareIndex + 1)")
            Spacer()
                .frame(height: 10)
            Text(coupon.bytewordsChecksum)
                .monospaced(size: 9, weight: .bold)
        }
    }
    
    func certificateBytewords(coupon: SSKRShareCoupon) -> some View {
        let a = Text(coupon.bytewordsBody + " ").monospaced(size: 9)
        let b = Text(coupon.bytewordsChecksum).monospaced(size: 9, weight: .bold)
        return (a + b).minimumScaleFactor(0.5)
    }
    
    func certificateUR(coupon: SSKRShareCoupon) -> some View {
        let t = Text(coupon.ur.description).monospaced(size: 9)
        return t.minimumScaleFactor(0.5)
    }

    func certificate(coupon: SSKRShareCoupon) -> some View {
        HStack {
            VStack(alignment: .leading) {
                ModelObjectIdentity(model: .constant(seed), allowLongPressCopy: false, generateLifeHashAsync: false, suppressName: true)
                    .frame(height: 64)
                certificateBytewords(coupon: coupon)
                    .layoutPriority(1)
                Spacer().frame(height: 5)
                certificateUR(coupon: coupon)
                Spacer()
            }
            qrCode(coupon: coupon)
        }
    }

    func qrCode(coupon: SSKRShareCoupon) -> some View {
        let message = coupon.ur.qrData
        let uiImage = makeQRCodeImage(message, correctionLevel: .low)
        let scaledImage = uiImage.scaled(by: 8)
        return Image(uiImage: scaledImage)
            .renderingMode(.template)
            .interpolation(.none)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    func hSpacer() -> some View {
        Spacer()
            .frame(height: 0.25 * pointsPerInch)
    }
    
    func hDivider() -> some View {
        Rectangle()
            .frame(height: 1)
    }
    
    func vSpacer() -> some View {
        Spacer()
            .frame(width: 0.25 * pointsPerInch)
    }
    
    func vDivider() -> some View {
        Rectangle()
            .frame(width: 1)
    }
}

#if DEBUG

import WolfLorem

struct SSKRPrintPage_Previews: PreviewProvider {
    static let model = Lorem.model()
    static let seed = model.seeds.first!
    static let generator = SSKRGenerator(seed: seed, sskrModel: SSKRPreset.modelTwoOfThreeOfTwoOfThree)
    static var previews: some View {
        PrintSetup(subject: generator, isPresented: .constant(true))
            .environmentObject(model)
    }
}
#endif
