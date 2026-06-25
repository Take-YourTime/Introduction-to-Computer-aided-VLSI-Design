// To understand this program logic, read Report.pdf first

#include <iostream>
#include <cstdlib>
#include <fstream>
#include <vector>
#include <algorithm>
#include <iomanip>
#include <utility>
#include <string>

#define MAX_NODE 200 // the max node number
using namespace std;

const string FILE1 = "DFG1.txt";
const string FILE2 = "DFG2.txt";

class Operation{
	public:
		int op;		// 1: add, 2: mul
		int node1;	// input node 1
		int node2;	// input node 2
		int result; // result value (current node value)
		
		int level = 1; // the critical path priority, the bigger the more important
		
		Operation() = default;
		Operation(int o, int n1, int n2, int r){
			this->op = o;
			this->node1 = n1;
			this->node2 = n2;
			this->result = r;
		}
		
};


vector<Operation> list;

// build crtical path priority
void DFS(const int* producer, int node, int level){
	if(producer[node] == -1) return;
	
	if(list[ producer[node] ].level >= level) return;
	
	list[ producer[node] ].level = level;
	
	DFS(producer, list[ producer[node] ].node1, level+1);
	DFS(producer, list[ producer[node] ].node2, level+1);
}


bool cmp(const Operation& a, const Operation& b){
	return a.level > b.level;
}


void setALU(vector< pair<int, int> >& ALU1, vector< pair<int, int> >& ALU2){
	// multiplier, adder
	ALU1.push_back( pair<int, int>(1, 1) );
	ALU1.push_back( pair<int, int>(1, 2) );
	ALU1.push_back( pair<int, int>(2, 1) );
	ALU1.push_back( pair<int, int>(2, 2) );
	
	ALU2.push_back( pair<int, int>(1, 1) );
	ALU2.push_back( pair<int, int>(1, 2) );
	ALU2.push_back( pair<int, int>(2, 1) );
	ALU2.push_back( pair<int, int>(2, 2) );
	ALU2.push_back( pair<int, int>(3, 1) );
	ALU2.push_back( pair<int, int>(3, 2) );
	ALU2.push_back( pair<int, int>(1, 3) );
	ALU2.push_back( pair<int, int>(2, 3) );
	ALU2.push_back( pair<int, int>(3, 3) );
}

int main()
{
	cout << "Which file do you want to open?\n";
	cout << "\t1) DFG1.txt\n";
	cout << "\t2) DFG2.txt\n";
	cout << "\t3) other~\n";
	
	int mode;
	int ALU_index;
	cin >> mode;
	string filename;
	switch(mode){
		case 1:
			ALU_index = 0;
			filename = FILE1;
			break;
		case 2:
			ALU_index = 1;
			filename = FILE2;
			break;
		case 3:
			ALU_index = 1;
			cout << "Type input file name: ";
			cin.ignore();
			getline(cin, filename);
			cout << "We will use the ALU resource as DFG2.txt.\n";
			break;
		default:
			cerr << "wrong mode!";
			exit(EXIT_FAILURE);
	}
	
	int op; // the number of operations
	
	// ALU resource
	vector< pair<int, int> > ALU[2];
	setALU(ALU[0], ALU[1]);
	
	
	// open file
	ifstream in;
	in.open(filename);
	if(!in.is_open()){
		cerr << "open failed!";
		exit(EXIT_FAILURE);
	}
	
	
	// read operation line number
	in >> op;
	
	
	int producer[MAX_NODE];	// the node value can get from which operation.
							// index: node, value: operation
	int producerSaved[MAX_NODE];
	
	// initialize to -1, which means this node is an outside input
	for(int i = 0; i < MAX_NODE; i++) producer[i] = -1;
	
	
	// input operation from file
	for(int i = 0; i < op; i++){
		int operation, node1, node2, result;
		in >> operation >> node1 >> node2 >> result;
		
		producer[result] = i;
		list.push_back( Operation(operation, node1, node2, result) );
	}
	
	// build critical path priority
	// 		Time complexity: O(V*E), V: node number, E: operation number
	//		If you want to speed up, you can use dynamic programming to calulate the critical path priority, 
	//		which can reduce the time complexity to O(V+E)
	for(int i = op-1; i >= 0; i--){
		int level = 1;
		// start from the last operation, which is the end of DFG, and do DFS to update the critical path priority
		DFS(producer, list[i].node1, level+1);
		DFS(producer, list[i].node2, level+1);
	}


	// saved data structure
	vector<Operation> listSaved(list);
	for (int i = 0; i < MAX_NODE; i++) { producerSaved[i] = producer[i]; }
	
	for(int round = 0; round < ALU[ALU_index].size(); round++){
		int pickCount = 1;
		int index;
		vector<Operation> ready; // ready queue
		
		// copy data from saved data structure
		list = listSaved; 
		for (int i = 0; i < MAX_NODE; i++) {
		    producer[i] = producerSaved[i];
		}
		
		cout << "[ALU Resource]\n";
		cout << "- Multiplier: " << ALU[ALU_index][round].first << '\n';
		cout << "- Adder: " << ALU[ALU_index][round].second << '\n';
		while(list.size() > 0 || ready.size() > 0)
		{
			if(list.size() > 0){
				index = 0;
				while(index < list.size()){
					// the both two node value are outside-input or finished 
					if( producer[list[index].node1] == -1 && producer[list[index].node2] == -1){
						// the operation is ready, take it form list to ready queue
						ready.push_back(list[index]);
						list.erase( list.begin()+index );
					}
					else{
						index++;
					}
				}
				
				// sort ready queue by the critical path proiority;
				stable_sort(ready.begin(), ready.end(), cmp); // merge sort, O(n^2)
			}
			
			int mul = ALU[ALU_index][round].first; // mul operation pick number
			int add = ALU[ALU_index][round].second; // add operation pick number
			
			
			cout << setw(3) << pickCount++ << " pick: ";
			
			int i = 0;
			while(i < ready.size() && (add > 0 || mul > 0) ){
				switch(ready[i].op){
					case 1:
						if(add <= 0){
							i++;
							continue;
						}
						
						add--;
						
						// pick add operation
						cout << "(" << setw(3) << ready[i].node1 << ") + (" << setw(3) << ready[i].node2 << ") = (" << setw(3) << ready[i].result << ")   ";
						
						// the result node can be use now~
						producer[ready[i].result] = -1;
						
						ready.erase(ready.begin()+i);
						break;
						
					case 2:
						if(mul <= 0){
							i++;
							continue;
						}
						
						mul--;
						
						// pick add operation
						cout << "(" << setw(3) << ready[i].node1 << ") * (" << setw(3) << ready[i].node2 << ") = ("<< setw(3) << ready[i].result << ")   ";
						
						// the result node can be use now~
						producer[ready[i].result] = -1;
						
						ready.erase(ready.begin()+i);
						break;
						
					default:
						cerr << "switch wrong";
						exit(EXIT_FAILURE);
				}
			}
			
			cout << '\n';
		}
		
		cout << '\n';
	}
	
	return 0;
}
