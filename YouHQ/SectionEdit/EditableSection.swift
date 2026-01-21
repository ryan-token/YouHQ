//
//  EditableSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import Foundation

enum EditableSection {
	case residenceInfo(Residence)
	case utility(Utility)
	case utilityDraft
	case insurancePolicy(InsurancePolicy)
	case insurancePolicyDraft
	case maintenanceItem(MaintenanceItem)
	case maintenanceItemDraft
	case paintColor(RoomPaintColor)
	case paintColorDraft
	case other(Other)
	case otherDraft

	var isDraft: Bool {
		switch self {
		case .residenceInfo, .utility, .insurancePolicy, .maintenanceItem,
			.paintColor, .other:
			false
		case .utilityDraft, .insurancePolicyDraft, .maintenanceItemDraft,
			.paintColorDraft, .otherDraft:
			true
		}
	}
}
