TITLE Dehumanizer ;
;===================== diferent herna
option casemap : none
.386
.MODEL flat, stdcall
;====================== includes
include		d:\soft\masm32\include\windows.inc
include		d:\soft\masm32\include\comdlg32.inc
include		d:\soft\masm32\include\kernel32.inc
include		d:\soft\masm32\include\user32.inc
include		Dehumanizer.inc
includelib	d:\soft\masm32\lib\kernel32.lib
includelib	d:\soft\masm32\lib\comdlg32.lib
includelib	d:\soft\masm32\lib\user32.lib

;====================== DATA
.DATA?
	hInst		DD		?
	buff		DB		256 DUP(?)
	ofn		OPENFILENAME	<?>
	hCrypterDll	DD		?
	infilebuff	DB		256 DUP(?)
	outfilebuff	DB		256 DUP(?)
.CODE
DlgID			DB		"Dehum1", 0
MainTitleStr		DB		":: Dehumanizer 0x0 :: by DeHunter", 0
AboutStr		DB		"Program     : Dehumanizer", 0AH, 0DH
			DB		"Version      : 0x0", 0AH, 0DH
			DB		"Author       : DeHunter", 0AH, 0DH
			DB		"Site           : dehunter.cjb.net", 0AH, 0DH
			DB		"EMail        : dehunter@inbox.ru", 0AH, 0DH
			DB		"Icq            : 280864324", 0AH, 0DH
			DB		"Gretz to :", 0AH, 0DH
			DB		"          - blacklogic.net(adminz and members)", 0AH, 0DH
			DB		"          - Microsoft", 0AH, 0DH
			DB		"          - PI[2005] coders group", 0AH, 0DH
			DB		"Special thanks to :", 0AH, 0DH
			DB		"               dzen", 0AH, 0DH
			DB		"               500mhz", 0AH, 0DH
			DB		"Thanks you for using my program. Now click ok to format your hdd =)", 0
			
			
InputFileStr		DB		"Select input file : ", 0
OutputFileStr		DB		"Select output file : ", 0 
CrypterFileStr		DB		"Select crypter dll : ", 0
OfnFilter		DB		"*.exe", 0,"*.exe", 0, "*.dll", 0, "*.dll", 0, "*.*", 0, "*.*", 0, 0
GetInfoProcStr		DB		"GetInfo", 0
CryptProcStr		DB		"Crypt", 0
NoInfoStr		DB		"No information for this crypter !", 0
DllNotLoadedStr		DB		"Hey man! You must load crypter at first !", 0
CantGetCryptProcStr	DB		"Can't get crypt proc address. May be dll is not crypter. Please stop your stupid jokes !", 0


;====================== CODE
;+++++++++++++++++++++ MAINDLG PROC
MainDlgProc		PROC	hDlg : DWORD, uMsg : DWORD, wParam : DWORD, lParam : DWORD 
	mov eax, uMsg
	cmp eax, WM_INITDIALOG
	jnz not_wm_init_dialog
	;---------- WM _INITDAILOG
		invoke LoadIcon, hInst, 10005
		xchg eax, ebx
		invoke SendMessage, hDlg, WM_SETICON, ICON_SMALL, ebx
		invoke SendMessage, hDlg, WM_SETICON, ICON_BIG, ebx
		jmp DlgCommandAccepted

	;---------------------
not_wm_init_dialog :
	cmp eax, WM_CLOSE
	jnz not_wm_close
;---------- WM _ CLOSE
	wm_close_lb :
		invoke EndDialog, hDlg, 0
		jmp DlgCommandAccepted
;---------------------
not_wm_close :
	cmp eax, WM_COMMAND
	jnz not_wm_command
;---------- WM_COMMAND
		mov eax, wParam
		cmp ax, IDC_BROWSEINPUTBTN
		jnz not_idc_inputbrowsebtn
		;-------- idc_inputbrowsebtn
			mov ofn.Flags, OFN_EXPLORER or OFN_FILEMUSTEXIST
			mov ofn.lpstrTitle, offset InputFileStr
			invoke GetOpenFileName, offset ofn
			test eax, eax
			jz DlgCommandAccepted
			invoke SetDlgItemText, hDlg, IDC_INPUTEDT, offset buff	
			jmp DlgCommandAccepted
			
		;---------------------------
	not_idc_inputbrowsebtn :
		cmp ax, IDC_BROWSEOUTPUTBTN
		jnz not_idc_outputbrowsebtn
		;-------- idc_outputbrowsebtn
			mov ofn.Flags, OFN_EXPLORER or OFN_NOREADONLYRETURN
			mov ofn.lpstrTitle, offset OutputFileStr
			invoke GetSaveFileName, offset ofn
			test eax, eax
			jz DlgCommandAccepted
			invoke SetDlgItemText, hDlg, IDC_OUTPUTEDT, offset buff	
			jmp DlgCommandAccepted
			
		;----------------------------
	not_idc_outputbrowsebtn :
		cmp ax, IDC_BROWSECRYPTBTN
		jnz not_idc_cryptbrowsebtn
		;-------- idc_cryptbrowsebtn
			mov ofn.Flags, OFN_EXPLORER or OFN_FILEMUSTEXIST or OFN_NOREADONLYRETURN
			mov ofn.lpstrTitle, offset CrypterFileStr
			mov ofn.lpstrFilter, offset OfnFilter+12
			invoke GetOpenFileName, offset ofn
			test eax, eax
			jz DlgCommandAccepted
			mov ofn.lpstrFilter, offset OfnFilter
			invoke SetDlgItemText, hDlg, IDC_CRYPTEREDT, offset buff	
			;-------- free previus library
			invoke FreeLibrary, hCrypterDll
			;-------- get info and set
			invoke LoadLibrary, offset buff
			mov hCrypterDll, eax
			invoke GetProcAddress, eax, offset GetInfoProcStr
			test eax, eax
			jnz proc_getted
				invoke SetDlgItemText, hDlg, IDC_INFOEDT, offset NoInfoStr
				jmp DlgCommandAccepted
		proc_getted :
			call eax
			invoke SetDlgItemText, hDlg, IDC_INFOEDT, eax
			jmp DlgCommandAccepted
			
		;-----------------------------
	not_idc_cryptbrowsebtn :
		cmp ax, IDC_CRYPTBTN
		jnz not_idc_cryptbtn
		;--------- idc_cryptbtn
			cmp hCrypterDll, 0
			jnz crypterdll_ok
			;---- if dll not loaded
				invoke MessageBoxA, 0, offset DllNotLoadedStr, offset MainTitleStr, 0
				jmp DlgCommandAccepted
		crypterdll_ok :
			invoke GetProcAddress, hCrypterDll, offset CryptProcStr
			test eax, eax
			jnz crypt_proc_getted_ok
				invoke MessageBoxA, 0, offset CantGetCryptProcStr, offset MainTitleStr, 0
				jmp DlgCommandAccepted
		crypt_proc_getted_ok :
		;----- call crypt proc
			xchg eax, ebx
			invoke GetDlgItemText, hDlg, IDC_OUTPUTEDT, offset outfilebuff, sizeof outfilebuff
			invoke GetDlgItemText, hDlg, IDC_INPUTEDT, offset infilebuff, sizeof infilebuff
			push offset outfilebuff
			push offset infilebuff
			call ebx
			jmp DlgCommandAccepted
			
		;----------------------
	not_idc_cryptbtn :
		cmp ax, IDC_ABOUTBTN
		jnz not_idc_aboutbtn
		;--------- idc_abputbtn
			invoke MessageBoxA, 0, offset AboutStr, offset MainTitleStr, 0
			jmp DlgCommandAccepted
			
		;----------------------
	not_idc_aboutbtn :
		cmp ax, IDC_EXITBTN
		jz wm_close_lb
	DlgCommandAccepted :
		xor eax, eax
		inc eax
		ret
;---------------------
not_wm_command :
;---------- DEFAULT
	xor eax, eax
	ret
MainDlgProc		ENDP

;+++++++++++++++ MAIN
start :
	mov hCrypterDll, 0
	invoke GetModuleHandle, 0
	mov hInst, eax
	;-------- init ofn struct
	invoke RtlZeroMemory, offset ofn, sizeof ofn
	mov ofn.lStructSize, sizeof ofn
	;mov ofn.hwndOwner, hDlg
	push eax
	pop ofn.hInstance
	mov ofn.lpstrFilter, offset OfnFilter
	mov ofn.nFilterIndex, 1
	mov ofn.lpstrFile, offset buff
	mov ofn.nMaxFile, sizeof buff
	;-------------------------
	invoke DialogBoxParam, eax, offset DlgID, 0, offset MainDlgProc, 0
	invoke ExitProcess, 0

END start
