//
//  EditableSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import Foundation

enum EditableSection {
	case residenceInfo(Residence)
	case utility(Utility, isNew: Bool)
	case insurancePolicy(InsurancePolicy, isNew: Bool)
	case maintenanceItem(MaintenanceItem, isNew: Bool)
	case other(Other, isNew: Bool)

	var isNew: Bool {
		switch self {
		case .residenceInfo:
			false
		case .utility(_, let isNew):
			isNew
		case .insurancePolicy(_, let isNew):
			isNew
		case .maintenanceItem(_, let isNew):
			isNew
		case .other(_, let isNew):
			isNew
		}
	}
}
