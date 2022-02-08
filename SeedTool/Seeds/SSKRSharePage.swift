//
//  SSKRSharePage.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 4/8/21.
//

import SwiftUI
import URUI
import BCFoundation

struct SSKRSharePage: View {
    let multipleSharesPerPage: Bool
    let seed: ModelSeed
    let coupons: [SSKRShareCoupon]
    
    var body: some View {
        VStack {
            if multipleSharesPerPage {
                VStack(alignment: .leading, spacing: 0) {
                    hDivider()
                    ForEach(coupons) { coupon in
                        couponView(coupon)
                    }
                }
                .font(.system(size: 12))
            } else {
                singleCouponView(coupons.first!)
            }
            Spacer()
        }
        .padding(0.25 * pointsPerInch)
    }
    
//    func header() -> some View {
//        HStack(alignment: .top) {
//            ObjectIdentityBlock(model: .constant(seed), allowLongPressCopy: false, generateVisualHashAsync: false)
//                .frame(height: 64)
//            VStack(alignment: .trailing) {
//                pageNumber()
//                groupsSummary()
//            }
//        }
//    }
    
//    func pageNumber() -> some View {
//        Text("Page \(pageIndex + 1) of \(pageCount)")
//    }
//
//    func groupsSummary() -> some View {
//        Text("Groups: \(groupThreshold) of \(groupsCount)")
//    }
    
    func couponView(_ coupon: SSKRShareCoupon) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        ObjectIdentityBlock(model: .constant(seed), allowLongPressCopy: false, generateVisualHashAsync: false, suppressName: true)
                            .frame(height: 64)
                        HStack(spacing: 20) {
                            groupText(coupon: coupon)
                            dateText(coupon: coupon)
                        }
                        .font(.system(size: 12))
                        byteWordsText(coupon: coupon)
                            .monospaced(size: 9)
                            .fixedVertical()
                        urText(coupon: coupon)
                            .monospaced(size: 9)
                            .fixedVertical()
                    }
                    qrCode(coupon: coupon)
                }
            }
            hSpacer()
            hDivider()
        }
        .frame(height: 2.0 * pointsPerInch)
        .padding([.top], 0.25 * pointsPerInch)
    }
    
    func singleCouponView(_ coupon: SSKRShareCoupon) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                ObjectIdentityBlock(model: .constant(seed), allowLongPressCopy: false, generateVisualHashAsync: false, visualHashWeight: 0.4, suppressName: true)
                qrCode(coupon: coupon)
            }
            .frame(height: 170)
            HStack(spacing: 20) {
                groupText(coupon: coupon)
                dateText(coupon: coupon)
            }
            .font(.system(size: 18))
            byteWordsText(coupon: coupon)
                .monospaced(size: 18)
            urText(coupon: coupon)
                .monospaced(size: 18)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .fixedVertical()
        }
    }
    
    var dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .none
        return f
    }()
    
    func groupText(coupon: SSKRShareCoupon) -> Text {
        Text("Group \(coupon.groupIndex + 1)")
    }
    
    func byteWordsText(coupon: SSKRShareCoupon) -> Text {
        let a = Text(coupon.bytewordsBody + " ")
        let b = Text(coupon.bytewordsChecksum).fontWeight(.bold)
        return a + b
    }
    
    func urText(coupon: SSKRShareCoupon) -> Text {
        Text(coupon.ur.description)
    }
    
    func dateText(coupon: SSKRShareCoupon) -> Text {
        Text(dateFormatter.string(from: coupon.date))
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
    static let generator: SSKRGenerator = {
        let gen = SSKRGenerator(seed: seed, sskrModel: SSKRPreset.modelTwoOfThreeOfTwoOfThree)
        gen.multipleSharesPerPage = true
        return gen
    }()
    static var previews: some View {
        PrintSetup(subject: .constant(generator), isPresented: .constant(true))
            .environmentObject(model)
    }
}
#endif
