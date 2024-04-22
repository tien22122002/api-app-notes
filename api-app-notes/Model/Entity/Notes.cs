using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace api_app_notes.Model.Entity
{
    public class Notes
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int NoteId { get; set; }
        public byte[] Title { get; set; }
        public byte[] Content { get; set; }
        public byte[] Day { get; set; }
        public byte[] Time { get; set; }
        public byte[] Pass { get; set; }
        public bool IsPinned { get; set; }
        [ForeignKey("Email")]
        public string Email { get; set; }

        public UserClient UserClient { get; set; }
    }

}
