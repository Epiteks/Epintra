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
	
	class func getInstance() -> DBManager
	{
		if(sharedInstance.database == nil)
		{
			sharedInstance.database = FMDatabase(path: Util.getPath("Students1.0.1.sqlite"))
		}
		return sharedInstance
	}
	
	func addStudentData(studentInfo: StudentInfo) -> Bool {
		database!.open()
		let isInserted = database!.executeUpdate("INSERT INTO student_info (login, ville, gpa, promo) VALUES (?, ?, ?, ?)", withArgumentsInArray: [studentInfo._login!, studentInfo._city!, studentInfo._gpa!, studentInfo._promo!])
		database!.close()
		return isInserted
	}
	
	//	func updateStudentData(studentInfo: StudentInfo) -> Bool {
	//		database!.open()
	//		let isUpdated = database!.executeUpdate("UPDATE student_info SET Name=?, Marks=? WHERE RollNo=?", withArgumentsInArray: [studentInfo.Name, studentInfo.Marks, studentInfo.RollNo])
	//		database!.close()
	//		return isUpdated
	//	}
	
	func deleteStudentData(studentInfo: StudentInfo) -> Bool {
		database!.open()
		let isDeleted = database!.executeUpdate("DELETE FROM student_info WHERE login=?", withArgumentsInArray: [studentInfo._login!])
		database!.close()
		return isDeleted
	}
	
	func cleanStudentData() -> Bool {
		database!.open()
		let isDeleted = database!.executeUpdate("DELETE FROM student_info", withArgumentsInArray: [AnyObject]())
		database!.close()
		return isDeleted
	}
	
	func getAllStudentData() -> NSMutableArray {
		database!.open()
		let resultSet: FMResultSet! = database!.executeQuery("SELECT * FROM student_info ORDER BY login", withArgumentsInArray: nil)
		let marrStudentInfo : NSMutableArray = NSMutableArray()
		if (resultSet != nil) {
			while resultSet.next() {
				let studentInfo : StudentInfo = StudentInfo()
				studentInfo._login = resultSet.stringForColumn("login")
				studentInfo._city = resultSet.stringForColumn("ville")
				studentInfo._gpa = Float(resultSet.stringForColumn("gpa"))
				studentInfo._promo = resultSet.stringForColumn("promo")
				marrStudentInfo.addObject(studentInfo)
			}
		}
		database!.close()
		return marrStudentInfo
	}
	
	func getStudentDataFor(Promo promo:String) -> NSMutableArray {
		database!.open()
		let resultSet: FMResultSet! = database!.executeQuery("SELECT * FROM student_info WHERE promo=?", withArgumentsInArray: [promo])
		let marrStudentInfo : NSMutableArray = NSMutableArray()
		var i = 1
		if (resultSet != nil) {
			while resultSet.next() {
				let studentInfo : StudentInfo = StudentInfo()
				studentInfo._login = resultSet.stringForColumn("login")
				studentInfo._city = resultSet.stringForColumn("ville")
				studentInfo._gpa = Float(resultSet.stringForColumn("gpa"))
				studentInfo._promo = resultSet.stringForColumn("promo")
				studentInfo._position = i
				i += 1
				marrStudentInfo.addObject(studentInfo)
			}
		}
		database!.close()
		return marrStudentInfo
	}
	
}
