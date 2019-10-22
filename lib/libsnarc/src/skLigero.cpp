#include "skLigero.hpp"
#include "r1cs_libiop.hpp"


#include "libiop/snark/ligero_snark.hpp"


#include <iostream>
#include <sstream>
#include <fstream>

using json = nlohmann::json;

using namespace libiop;

 //Generate the proof from a (trusted) setup
nlohmann::json  skLigero::Proof(const std::string &r1cs_filename,  const std::string &trustedSetup)
{
    typedef libff::alt_bn128_Fr FieldT;
    alt_bn128_pp::init_public_params();
    /* Set up R1CS */
    R1CSLibiop<FieldT> r1cs;
  std::string inputsFile = r1cs_filename + ".in";
	r1cs_constraint_system<FieldT> cs;
	r1cs.FromJsonl(r1cs_filename, cs);
	//load the inputs
  r1cs_primary_input<FieldT> primary_input;
	r1cs_auxiliary_input<FieldT> auxiliary_input;
	if (r1cs.LoadInputs(inputsFile, primary_input, auxiliary_input))
		printf("inputs are loaded\n");
	else
		printf("error with inputs file\n");

	if(!cs.is_satisfied(primary_input, auxiliary_input))
		printf("NOT SATISFIED!!!\n");

    /* Actual SNARK test */
    ligero_snark_parameters<FieldT> parameters;
    parameters.security_level_ = 128;
    parameters.height_width_ratio_ = 0.001;
    parameters.RS_extra_dimensions_ = 2;
    parameters.make_zk_ = true;
    parameters.domain_type_ = multiplicative_coset_type;
    parameters.LDT_reducer_soundness_type_ = LDT_reducer_soundness_type::proven;

    const ligero_snark_argument<FieldT> argument =
        ligero_snark_prover<FieldT>(cs, primary_input, auxiliary_input, parameters);
    const bool bit = ligero_snark_verifier<FieldT>(cs, primary_input, argument, parameters);

//TODO serialization..
    json proof;
    if (bit == true)
		printf("PASS\n");
	else
		printf("verification FAILED\n");
    return proof;

//.................
    
}