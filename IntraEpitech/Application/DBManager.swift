//
//  DBManager.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 21/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import FMDB

class DBManager: NSObject {
	
	static let sharedInstance = DBManager()
	
	var database :FMDatabase? = nil
	
	class func getInstance() -> DBManager {
		if sharedInstance.database == nil {
			sharedInstance.database = FMDatabase(path: Util.getPath("Students1.0.1.sqlite"))
		}
		return sharedInstance
	}
	
	func addStudentData(_ studentInfo: StudentInfo) -> Bool {
		database!.open()
		let isInserted = database!.executeUpdate("INSERT INTO student_info (login, ville, gpa, promo) VALUES (?, ?, ?, ?)", withArgumentsIn: [studentInfo.login!, studentInfo.city!, studentInfo.gpa!, studentInfo.promo!])
		database!.close()
		return isInserted
	}
	
	//	func updateStudentData(studentInfo: StudentInfo) -> Bool {
	//		database!.open()
	//		let isUpdated = database!.executeUpdate("UPDATE student_info SET Name=?, Marks=? WHERE RollNo=?", withArgumentsInArray: [studentInfo.Name, studentInfo.Marks, studentInfo.RollNo])
	//		database!.close()
	//		return isUpdated
	//	}
	
	func deleteStudentData(_ studentInfo: StudentInfo) -> Bool {
		database!.open()
		let isDeleted = database!.executeUpdate("DELETE FROM student_info WHERE login=?", withArgumentsIn: [studentInfo.login!])
		database!.close()
		return isDeleted
	}
	
	func cleanStudentData() -> Bool {
		database!.open()
		let isDeleted = database!.executeUpdate("DELETE FROM student_info", withArgumentsIn: [AnyObject]())
		database!.close()
		return isDeleted
	}
	
	func getAllStudentData() -> NSMutableArray {
		database!.open()
		let resultSet: FMResultSet! = database!.executeQuery("SELECT * FROM student_info ORDER BY login", withArgumentsIn: nil)
		let marrStudentInfo : NSMutableArray = NSMutableArray()
		if (resultSet != nil) {
			while resultSet.next() {
				let studentInfo : StudentInfo = StudentInfo()
				studentInfo.login = resultSet.string(forColumn: "login")
				studentInfo.city = resultSet.string(forColumn: "ville")
				studentInfo.gpa = Float(resultSet.string(forColumn: "gpa"))
				studentInfo.promo = resultSet.string(forColumn: "promo")
				marrStudentInfo.add(studentInfo)
			}
		}
		database!.close()
		return marrStudentInfo
	}
	
	func getStudentDataFor(Promo promo:String) -> NSMutableArray {
		database!.open()
		let resultSet: FMResultSet! = database!.executeQuery("SELECT * FROM student_info WHERE promo=?", withArgumentsIn: [promo])
		let marrStudentInfo : NSMutableArray = NSMutableArray()
		var i = 1
		if (resultSet != nil) {
			while resultSet.next() {
				let studentInfo : StudentInfo = StudentInfo()
				studentInfo.login = resultSet.string(forColumn: "login")
				studentInfo.city = resultSet.string(forColumn: "ville")
				studentInfo.gpa = Float(resultSet.string(forColumn: "gpa"))
				studentInfo.promo = resultSet.string(forColumn: "promo")
				studentInfo.position = i
				i += 1
				marrStudentInfo.add(studentInfo)
			}
		}
		database!.close()
		return marrStudentInfo
	}
	
}
