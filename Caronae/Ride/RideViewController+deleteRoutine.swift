import SVProgressHUD

extension RideViewController {
    func deleteRoutine() {
        let routineID = self.ride.routineID.value!
        NSLog("Requesting to delete routine with id %ld", routineID)
        
        cancelButton.isEnabled = false
        SVProgressHUD.show()
        
        RideService.instance.deleteRoutine(withID: routineID, success: { 
            SVProgressHUD.dismiss()
            NSLog("User left all rides from routine.")
            
            _ = self.navigationController?.popViewController(animated: true)
        }, error: { error in
            SVProgressHUD.dismiss()
            self.cancelButton.isEnabled = true
            NSLog("Error deleting routine (%@)", error.localizedDescription)
            
            CaronaeAlertController.presentOkAlert(withTitle: "Algo deu errado.", message: String(format: "Não foi possível cancelar sua rotina. (%@)", error.localizedDescription))
        })
    }
}
