import SwiftUI

// MARK: - Font System
// Centralized typography matching Habitto-style design tokens.
// Use these font names instead of ad-hoc .font(.system(...)) for consistency.

extension Font {
  // MARK: - Display

  static let appDisplayLarge = Font.system(size: 57, weight: .regular)
  static let appDisplayLargeEmphasised = Font.system(size: 57, weight: .medium)
  static let appDisplayMedium = Font.system(size: 45, weight: .medium)
  static let appDisplayMediumEmphasised = Font.system(size: 45, weight: .bold)
  static let appDisplaySmall = Font.system(size: 36, weight: .regular)
  static let appDisplaySmallEmphasised = Font.system(size: 36, weight: .medium)

  // MARK: - Headline

  static let appHeadlineLarge = Font.system(size: 32, weight: .regular)
  static let appHeadlineLargeEmphasised = Font.system(size: 32, weight: .semibold)
  static let appHeadlineMedium = Font.system(size: 28, weight: .regular)
  static let appHeadlineMediumEmphasised = Font.system(size: 28, weight: .semibold)
  static let appHeadlineSmall = Font.system(size: 24, weight: .regular)
  static let appHeadlineSmallEmphasised = Font.system(size: 24, weight: .semibold)

  // MARK: - Title

  static let appTitleLarge = Font.system(size: 18, weight: .medium)
  static let appTitleLargeEmphasised = Font.system(size: 18, weight: .semibold)
  static let appTitleMedium = Font.system(size: 16, weight: .medium)
  static let appTitleMediumEmphasised = Font.system(size: 16, weight: .semibold)
  static let appTitleSmall = Font.system(size: 14, weight: .medium)
  static let appTitleSmallEmphasised = Font.system(size: 14, weight: .semibold)

  // MARK: - Label

  static let appLabelLarge = Font.system(size: 14, weight: .medium)
  static let appLabelLargeEmphasised = Font.system(size: 14, weight: .semibold)
  static let appLabelMedium = Font.system(size: 12, weight: .medium)
  static let appLabelMediumEmphasised = Font.system(size: 12, weight: .semibold)
  static let appLabelSmall = Font.system(size: 11, weight: .medium)
  static let appLabelSmallEmphasised = Font.system(size: 11, weight: .semibold)

  // MARK: - Body

  static let appBodyExtraLarge = Font.system(size: 18, weight: .regular)
  static let appBodyLarge = Font.system(size: 16, weight: .regular)
  static let appBodyLargeEmphasised = Font.system(size: 16, weight: .medium)
  static let appBodyMedium = Font.system(size: 14, weight: .regular)
  static let appBodyMediumEmphasised = Font.system(size: 14, weight: .medium)
  static let appBodySmall = Font.system(size: 12, weight: .regular)
  static let appBodySmallEmphasised = Font.system(size: 12, weight: .medium)
  static let appBodyExtraSmall = Font.system(size: 10, weight: .regular)

  // MARK: - Caption

  static let appCaptionLarge = Font.system(size: 12, weight: .medium)
  static let appCaptionMedium = Font.system(size: 11, weight: .medium)
  static let appCaptionSmall = Font.system(size: 10, weight: .medium)

  // MARK: - Button Text

  static let appButtonText1 = Font.system(size: 18, weight: .semibold)
  static let appButtonText2 = Font.system(size: 16, weight: .medium)
  static let appButtonText3 = Font.system(size: 14, weight: .medium)
}

// MARK: - View helpers (optional)

extension View {
  func appBodyLargeFont() -> some View { font(.appBodyLarge) }
  func appTitleMediumFont() -> some View { font(.appTitleMedium) }
  func appButtonTextFont() -> some View { font(.appButtonText1) }
  func appLabelMediumFont() -> some View { font(.appLabelMedium) }
  func appTitleSmallFont() -> some View { font(.appTitleSmall) }
  func appHeadlineSmallEmphasisedFont() -> some View { font(.appHeadlineSmallEmphasised) }
  func appLabelMediumEmphasisedFont() -> some View { font(.appLabelMediumEmphasised) }
}
