#include <iostream>
#include <vector>
#include <algorithm>
#include <iomanip>
using namespace std;


bool cmp(const vector<int>& a, const vector<int>& b)
{
	return a.size() > b.size();
}


int main()
{
	bool a3, a2, a1, a0;
	bool n1, n2, n3;
	bool y, yTest;
	
	
	string table[16] = {
		"A3		SA1",
		"A3 	SA0",
		"A2 	SA1",
		"A2 	SA0",
		"A1 	SA1",
		"A1 	SA0",
		"A0 	SA1",
		"A0 	SA0",
		"n1 	SA1",
		"n1 	SA0",
		"n2 	SA1",
		"n2 	SA0",
		"n3 	SA1",
		"n3 	SA0",
		"Y  	SA1",
		"Y  	SA0"
	};
	
	
	bool matrix[16][16] = {false}; // record which number (express by row number) can detect the situation
	/*
	
	row		node	stuck value		0	1	2	3	4	5	6	7	8	9	10	11	12	13	14	15
	-		-		-
	1 		A3 		SA1
	2 		A3 		SA0
	3 		A2 		SA1
	4 		A2 		SA0
	5 		A1 		SA1
	6 		A1 		SA0
	7 		A0 		SA1
	8 		A0 		SA0
	9 		n1 		SA1
	10 		n1 		SA0
	11 		n2 		SA1
	12 		n2 		SA0
	13 		n3 		SA1
	14 		n3 		SA0
	15 		Y  		SA1
	16 		Y  		SA0
	*/
	
	cout << "【Bit Sequence】\n";
	// 0 to 15
	for(int i = 0; i < 16; i++)
	{
		a3 = (i >> 3) & 1;
		a2 = (i >> 2) & 1;
		a1 = (i >> 1) & 1;
		a0 = i & 1;
		
		cout << "input number: " << a3 << a2 << a1 << a0 << '\n';
		
		
		n1 = !(a3 & a2);
		n2 = !a1;
		n3 = !(n2 | a0);
		y = !(n1 & n3);
		
		cout << "Node value: " << n1 << n2 << n3 << y << '\n';
		cout << '\n';
		
		// a3, 將a3反向，如果結果y改變，代表可以透過當前輸入判斷a3 atuck at (a3反向)
		n1 = !((!a3) & a2);
		n2 = !a1;
		n3 = !(n2 | a0);
		yTest = !(n1 & n3);
		if(yTest != y){
			matrix[ 1-(!a3) ][i] = true;
		}
		
		// a2
		n1 = !(a3 & (!a2));
		n2 = !a1;
		n3 = !(n2 | a0);
		yTest = !(n1 & n3);
		if(yTest != y){
			matrix[ 3-(!a2) ][i] = true;
		}
		
		// a1
		n1 = !(a3 & a2);
		n2 = !(!a1);
		n3 = !(n2 | a0);
		yTest = !(n1 & n3);
		if(yTest != y){
			matrix[ 5-(!a1) ][i] = true;
		}
		
		// a0
		n1 = !(a3 & a2);
		n2 = !a1;
		n3 = !(n2 | (!a0));
		yTest = !(n1 & n3);
		if(yTest != y){
			matrix[ 7-(!a0) ][i] = true;
		}
		
		// n1
		n1 = !(a3 & a2);
		n2 = !a1;
		n3 = !(n2 | a0);
		yTest = !((!n1) & n3);
		if(yTest != y){
			matrix[ 9-(!n1) ][i] = true;
		}
		
		// n2
		n1 = !(a3 & a2);
		n2 = !a1;
		n3 = !((!n2) | a0);
		yTest = !(n1 & n3);
		if(yTest != y){
			matrix[ 11-(!n2) ][i] = true;
		}
		
		// n3
		n1 = !(a3 & a2);
		n2 = !a1;
		n3 = !(n2 | a0);
		yTest = !(n1 & (!n3));
		if(yTest != y){
			matrix[ 13-(!n3) ][i] = true;
		}
		
		// y
		n1 = !(a3 & a2);
		n2 = !a1;
		n3 = !(n2 | a0);
		yTest = !(n1 & n3);
		if((!yTest) != y){
			matrix[ 15-(!y) ][i] = true;
		}
		
	}
	
	
	vector<int> canDetect[16];	// the index value means the input number of circuit, 
								// and the store number means this input number can detect which situatuon
	
	// the first number of each element is the "input number"
	// this is used to know the final Minimum Test Pattern Set
	for(int inputNumber = 0; inputNumber < 16; inputNumber++) canDetect[inputNumber].push_back(inputNumber);
	
	// output "situation to input number" matrix
	cout << "【Node state to input number matrix】\n";
	cout << "       \t\t   "; for(int i = 0; i < 16; i++) { cout << setw(3) << i; } cout << '\n';
	for(int i = 0; i < 16; i++){
		cout << "SA" << setw(2) << i+1 << " " << table[i];
		for(int j = 0; j < 16; j++){
			cout << "  " << matrix[i][j];
			
			if(matrix[i][j]) canDetect[j].push_back(i);
		}
		cout << '\n';
	}
	cout << '\n';
	
	// sort canDetect by the element size, big to small
	sort(canDetect, canDetect+16, cmp);
	
	
	int count = 0;
	int zeroCount = 0; // zero size element count
	int index = 0;
	vector<int> minAnsSet;
	vector<int> newStateThisRound;
	
	/* Get a Minimum Test Pattern Set by Greedy */
	// we have sort the vector array - "input number to situation index can be detect" accroading to the number of "situation index can be detect"
	// Thus we take the largest size of "situation index can be detect" each round, 
	// and check if there is at least one number not be record by array choose[],
	// then mark and record all the "situation index can be detect" in choose[],
	// do next round until all the situation can be detect, the picked input number is Minimum Test Pattern Set
	cout << "【Find the Minimum Test Pattern Set process】\n";
	for(int i = 0; i < 16; i++){
		newStateThisRound.clear();
		
		// record current input as a number of Minimum Test Pattern Set
		minAnsSet.push_back(canDetect[i][0]);
		
		// record the state theat can be choose in this round
		for(int situaionIndex = 1; situaionIndex < canDetect[i].size(); situaionIndex++){
			newStateThisRound.push_back(canDetect[i][situaionIndex]);	
		}
		
		
		cout << "Choose " << canDetect[i][0] << ", newStateThisRound: ";
		for(int n : newStateThisRound) cout << n << " ";
		cout << '\n';
		
		
		// Update count and detect whether find the Minimum Test Pattern Set or not
		count += newStateThisRound.size();
		if(count == 16){
			cout << "Find Minimum Test Pattern Set!\n";
			break;
		}
		
		for(int j = i+1; j < 16; j++){
			cout << "- Input number " << setw(2) << canDetect[j][0] << ":";
			for(int k = 1; k < canDetect[j].size(); k++) cout << " " << setw(2) << canDetect[j][k];
			cout << '\n';
		}
		cout << '\n';
		
		// delete the new checked state in undetect sequence (i+1 ~ 15)
		int newZeroCount = 0;
		for(int j = i+1; j < 16-zeroCount; j++){
			int newStateIndex = 0;
			int undetectIndex = 1;
			
			while(newStateIndex < newStateThisRound.size() && undetectIndex < canDetect[j].size()){
				if(canDetect[j][undetectIndex] < newStateThisRound[newStateIndex]){
					undetectIndex++;
				}
				else if(canDetect[j][undetectIndex] == newStateThisRound[newStateIndex]){
					canDetect[j].erase( canDetect[j].begin() + undetectIndex );
				}
				else{// canDetect[j][undetectIndex] > newStateThisRound[newStateIndex]
					newStateIndex++;
				}
			}
			
			if(canDetect[j].size() == 1) newZeroCount++;
		}
		
		// sort the rest elements
		sort(canDetect + (i+1), canDetect + (16-zeroCount), cmp);
		
		// update zero size element count
		zeroCount += newZeroCount;
		
		
		cout << "After delete and sort ( no output zero size element )\n";
		for(int j = i+1; j < 16-zeroCount; j++){
			cout << "- Input number " << setw(2) << canDetect[j][0] << ":";
			for(int k = 1; k < canDetect[j].size(); k++) cout << " " << setw(2) << canDetect[j][k];
			cout << '\n';
		}
		cout << '\n';
	}
	
	
	// final output
	cout << "\n\n\n【Minimum Test Pattern Set】\n";
	for(int n : minAnsSet) cout << n << " ";
	cout << '\n';
	
	return 0;
}
